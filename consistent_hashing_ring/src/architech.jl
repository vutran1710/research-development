using UUIDs: uuid1
using Faker

function create_records(num::Integer)
    ids = Iterators.Stateful(1:1000)
    id = () -> popfirst!(ids)
    name = () -> "$(Faker.first_name()) $(Faker.last_name())"
    create_record = _ -> Record(id(), name())
    map(create_record, 1:num)
end


function create_cache_servers(num::Integer)
    ids = [string(uuid1())[end-5:end] for _=1:num]
    id = () -> popfirst!(ids)
    bucket = () -> Bucket(Dict())
    create_server = _ -> CacheServer(id(), bucket())
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


function add_to_cache(record_id::Integer, cache::CacheServer, store::PersistentStorage)
    idx = findfirst(x -> x.id == record_id, store.data)
    if idx != nothing
        record = store.data[idx]
        push!(cache.bucket.data, record.id => record)
    end
end


function hashing_oject(record_id::Integer)
    # NOTE: multiply by 15 so the degree will increase faster
    # and thus more evenly distributed
    pi_angle = record_id * 15 * π / 180
    return round(mod(pi_angle, 2π), digits=3)
end

function locate_cache(cluster::ConsistentHashingTable, hashed::Float64)
    idx = findfirst(angle -> angle ≥ hashed, cluster.list)
    cache_angle_idx = (idx != nothing && idx > 1) ? idx - 1 : 1
    angle =  cluster.list[cache_angle_idx]
    cache = cluster.map[angle]
    return cache, angle
end
