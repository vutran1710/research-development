using Logging
using UUIDs: uuid1
using Faker: first_name, last_name

global_logger()


# ARCHITECH
function create_records(; start::Integer=1, stop::Integer=1000)
    ids = Iterators.Stateful(start:stop)
    id = () -> popfirst!(ids)
    name = () -> "$(first_name()) $(last_name())"
    create_record = _ -> Record(id(), name())
    map(create_record, 1:(stop-start))
end


function create_cache_servers(num::Integer)
    ids = [string(uuid1())[end-5:end] for _=1:num]
    id = () -> "cache-$(popfirst!(ids))"
    create_server = _ -> CacheServer(id(), Dict())
    map(create_server, 1:num)
end


function consistent_hashing(servers::Array{CacheServer}, label_multiplier::Integer)
    count = length(servers)
    @assert mod(count + label_multiplier, min(label_multiplier, count)) !== 0
    angle_block = 2π / count
    angle_step = 2π / (count * label_multiplier)
    angle_map = Dict()
    angle_list = []
    server_map = Dict()

    for i in 1:count
        id = servers[i].id
        base_angle = (i - 1) * angle_block
        angle_group = []

        for j in 1:label_multiplier
            real_angle = base_angle + j * count * angle_step
            angle = round(mod(real_angle, 2π), digits=3)
            angle_map[angle] = id
            push!(angle_group, angle)
            push!(angle_list, angle)
        end

        server_map[id] = angle_group
        sort!(angle_list)
    end

    return ConsistentHashingTable(angle_map, angle_list, server_map)
end


function hashing_oject(record_id::RecordID)::Angle
    # NOTE: multiply by 5 so the degree will increase faster
    # and thus more evenly distributed
    pi_angle = record_id * 5 * π / 180
    return round(mod(pi_angle, 2π), digits=3)
end


function locate_cache(table::ConsistentHashingTable, hashed::Angle)
    idx = findfirst(angle -> angle ≥ hashed, table.list)

    if idx == nothing
        idx = 1
    end

    angle = table.list[idx]
    cache = table.map[angle]
    return cache, angle
end


function construct(record_count::Integer, server_count::Integer, label_replica_count::Integer)::TheSystem
    records = create_records(start=1, stop=record_count+1)
    storage = PersistentStorage(records)
    caches = create_cache_servers(server_count)
    table = consistent_hashing(caches, label_replica_count)
    cache_cluster_map = Dict(svr.id => svr for svr ∈ caches)

    try_except = handler -> (params...) -> begin
        try
            result, status = handler(params...)
            ResponseMessage(result, status)
        catch e
            @error (e)
            ResponseMessage(nothing, SYSTEM_ERROR)
        end
    end

    function get_record(id::RecordID)
        @info "Querying record....: $(id)"

        if id > 100
            throw(DomainError(id, "ID too large... $(id) > 100"))
        end

        hashed = hashing_oject(id)
        cache_id, _ = locate_cache(table, hashed)
        bucket = cache_cluster_map[cache_id].bucket

        if haskey(bucket, id)
            @info "Cache-hit!"
            record = bucket[id]
            return record, SUCCESS
        end

        @warn "Cache-miss!"
        # NOTE: pull from cold-storage, then save to cache
        record = findfirst(r -> r.id == id, storage.data)
        record, record != nothing ? SUCCESS : NOT_FOUND
    end

    function add_records(record_number::Integer)
        start = length(storage.data) + 1
        stop = start + record_number
        records = create_records(start=start, stop=stop)
        foreach(r -> push!(storage.data, r), records)
        nothing, SUCCESS
    end

    function inspect_cache_ids()
        cache_ids = map(c -> c.id, caches)
        cache_ids, SUCCESS
    end

    function inspect_cache_data(cache_id::ServerID)
        if haskey(cache_cluster_map, cache_id)
            bucket = cache_cluster_map[cache_id].bucket
            bucket, SUCCESS
        else
            nothing, NOT_FOUND
        end
    end

    return TheSystem(
        try_except(get_record),
        try_except(add_records),
        try_except(inspect_cache_ids),
        try_except(inspect_cache_data),
        storage,
        table,
    )
end
