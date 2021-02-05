using UUIDs: uuid1
using Faker: first_name, last_name


function create_records(num::Integer)
    ids = Iterators.Stateful(1:1000)
    id = () -> popfirst!(ids)
    name = () -> "$(first_name()) $(last_name())"
    create_record = _ -> Record(id(), name())
    map(create_record, 1:num)
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
    angle_block = (2 / count)π
    angle_step = (2 / count / label_multiplier)π
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


function construct_system(
    storage::PersistentStorage,
    caches::Array{CacheServer},
    table::ConsistentHashingTable,
)::TheSystem
    cache_cluster_map = Dict(svr.id => svr for svr ∈ caches)

    function query(id)::ResponseMessage
        hashed = hashing_oject(id)
        cache_id, _ = locate_cache(table, hashed)
        cache_svr = cache_cluster_map[cache_id]
        bucket = cache_svr.bucket

        if haskey(bucket, id)
            record = bucket[id]
            return ResponseMessage(record, SUCCESS)
        end

        return ResponseMessage(nothing, NOT_FOUND)
    end

    return TheSystem(query)
end
