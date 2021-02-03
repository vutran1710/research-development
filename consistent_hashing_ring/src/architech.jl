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
    bucket = () -> Bucket([])
    create_server = _ -> CacheServer(id(), bucket())
    map(create_server, 1:num)
end


function consistent_hashing(servers::Array{CacheServer}, label_multiplier::Integer)
    count = length(servers)
    angle_block = (2 / count)π
    place = i -> (i - 1) * angle_block
    base_positions = map(place, 1:count)
    angle_step = (2 / count / label_multiplier)π
    angle_map = Dict()
    angle_list = []

    for i in 1:count
        id = servers[i].id
        base_angle = base_positions[i]

        for j in 1:label_multiplier
            angle = round(base_angle + j * count * angle_step, digits=2)
            angle_map[angle] = id
            push!(angle_list, angle)
        end

        sort!(angle_list)

    end

    return ConsistentHashingTable(angle_map, angle_list)
end
