module test1
using Test
include("../structs.jl")
include("../architech.jl")


rec = create_records(5)
println(rec)
@test length(rec) == 5

store = PersistentStorage(rec)
println(store)
@test length(store.data) == 5
@test store.data[1].id isa Integer
@test store.data[1].name isa String

caches = create_cache_servers(5)
println(caches)
@test length(caches) == 5
@test caches[1].id isa String
@test length(keys(caches[1].bucket.data)) == 0

label_multiplier = 7
ch_table = consistent_hashing(caches, label_multiplier)
println(ch_table)
@test length(keys(ch_table.map)) == label_multiplier * 5
@test length(ch_table.list) == label_multiplier * 5

add_to_cache(1, caches[1], store)
println(caches[1].bucket.data[1])
@test caches[1].bucket.data[1] != nothing

println("===========================================")
hashed = hashing_oject(99)
println(hashed)
cache, angle = locate_cache(ch_table, hashed)
println(cache)
println(angle)
@test cache != nothing

end
