module test1
using Test
using JSON
include("../structs.jl")
include("../architech.jl")

# Given inputs ========================================================
server_count = 3
label_multiplier = 10
record_count = 5

# Setup ===============================================================
rec = create_records(record_count)
@test length(rec) == record_count
@test rec[1] isa Record

store = PersistentStorage(rec)
@test length(store.data) == record_count
@test store.data[1].id isa Integer
@test store.data[1].name isa String

caches = create_cache_servers(server_count)
@test length(caches) == server_count
@test caches[1].id isa String
@test length(keys(caches[1].bucket.data)) == 0

ch_table = consistent_hashing(caches, label_multiplier)
@test length(keys(ch_table.map)) == label_multiplier * server_count
@test length(ch_table.list) == label_multiplier * server_count

add_to_cache(1, caches[1], store)
@test caches[1].bucket.data[1] != nothing

# Distributed Hashing should be fairly even ============================
distribution_count = Dict()
for sample_id in 1:1000
    hashed = hashing_oject(sample_id)
    cache_id, angle = locate_cache(ch_table, hashed)
    count = get(distribution_count, cache_id, 0)
    distribution_count[cache_id] = count + 1
end

println(json(distribution_count, 2))



end
