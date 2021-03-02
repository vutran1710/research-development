# ARCHITECH
Row = NamedTuple

function create_records(; start::Integer=1, stop::Integer=1000)::Array{Record}
    ids = Iterators.Stateful(start:stop)
    id = () -> popfirst!(ids)
    name = () -> "$(first_name()) $(last_name())"
    create_record = _ -> Record(id(), name())
    map(create_record, 1:(stop-start+1))
end


function init_storage(records::Array{Record})::PersistentStorage
    ids = map(r -> r.id, records)
    names = map(r -> r.name, records)
    table = Table(id=ids, name=names)
    PersistentStorage(table)
end


function add_records(records::Array{Record}, storage::PersistentStorage)
    for r in records
        push!(storage.table.id, r.id)
        push!(storage.table.name, r.name)
    end
end


function create_cache_servers(num::Integer)::Array{CacheServer}
    ids = [string(uuid1())[end-5:end] for _=1:num]
    id = () -> popfirst!(ids)
    create_server = _ -> CacheServer(id(), Dict())
    map(create_server, 1:num)
end


function hashing(number::Integer)::Angle
    mod(number, 360)
end


function pin_servers(servers::Array{CacheServer})::Table
    number = length(servers)
    segment_angle = 360 / number
    points = map(i -> round(i * segment_angle, digits=3), 0:(number-1))
    server_ids = map(s -> s.id, servers)
    Table(server=server_ids, angle=points)
end


function locate_cache(hashed::Angle, server_table::Table)::Row
    """ We find the nearest cache-id in the counter-clockwise direction
    whose angle is greater than the hashed
    """
    last_row, first_row = server_table[end], server_table[1]

    if hashed > last_row.angle
        return first_row
    end

    idx = findfirst(row -> row.angle >= hashed, server_table)
    row = server_table[idx]
    return row
end


function derive_server_labels(server_table::Table, derive_labels::Integer)::Table
    labels, angles, server_ids = [], [], []
    chars = Iterators.Stateful('A':'Z')
    segment_angle = rand(0:360)

    for row in server_table
        char = popfirst!(chars)
        for nth in 0:(derive_labels-1)
            label = "$(char)$(nth)"
            angle = round(row.angle + nth * segment_angle, digits=3)
            push!(labels, label)
            push!(angles, angle)
            push!(server_ids, row.server)
        end
    end

    online_stat = map(_ -> true, 1:length(server_ids))
    Table(label=labels, angle=angles, server=server_ids, online=online_stat)
end


function construct(
    number_of_records::Integer,
    number_of_caches::Integer,
    number_of_labels::Integer,
)
    records = create_records(stop=number_of_records)
    caches = create_cache_servers(number_of_caches)
    cache_map = reduce((r, s) -> push!(r, s.id => s), caches, init=Dict())
    storage = init_storage(records)
    cache_table = pin_servers(caches)
    cache_hash_table = derive_server_labels(cache_table, number_of_labels)

    println("============== System Components ==============")
    println("> Cache Hash Table ----------------------------")
    print(cache_hash_table)
    print("\n\n")
    println("> Cache Map -----------------------------------")
    pprint(cache_map)
    print("\n\n")
    println("> Storage -------------------------------------")
    pprint(storage.table)
    print("\n\n")
    println("===============================================")

    api__get_record(id::RecordID) = begin
        hashed = hashing(id)
        row = locate_cache(hashed, cache_hash_table)
        cache_id = row.server
        cache_server = cache_map[cache_id]
        bucket = cache_server.bucket

        if !haskey(bucket, id)
            @info "Cache miss"
            idx = findfirst(r -> r.id == id, storage.table)
            status = idx != nothing ? SUCCESS : NOT_FOUND
            row = idx != nothing ? storage.table[idx] : nothing

            if row != nothing
                @info "Caching record_id=$(id) to $(cache_id)"
                push!(bucket, id => Record(id, row.name))
            end

            ResponseMessage(Record(row.id, row.name), status)
        else
            @info "Cache hit"
            ResponseMessage(bucket[id], SUCCESS)
        end
    end

    api__add_records(number::Integer) = begin
        start = length(storage.table) + 1
        stop = start + number - 1
        new_records = create_records(start=start, stop=stop)
        add_records(new_records, storage)
        println(storage.table)
    end

    inspect__cache_data(cache_id::ServerID) = begin
        if !hashkey(cache_map, cache_id)
            @error "Cache-ID=$(cache_id) does not exist"
        end
        cache_map[cache_id].bucket
    end

    TheSystem(
        api__get_record,
        api__add_records,
        inspect__cache_data,
        storage,
        cache_hash_table,
    )
end
