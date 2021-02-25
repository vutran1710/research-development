using Test
using JSON
using Logging
include("../src/structs.jl")
include("../src/architech.jl")
include("../src/plotf.jl")
include("../src/cli.jl")

logger = SimpleLogger()
global_logger(logger)


@testset "consistent-hashing system" begin
    # Given inputs ========================================================
    server_count = 4
    label_multiplier = 7
    record_count = 1000


    # Setup ===============================================================
    rec = create_records(start=1, stop=record_count+1)
    @test length(rec) == record_count
    @test rec[1] isa Record

    storage = PersistentStorage(rec)
    @test length(storage.data) == record_count
    @test storage.data[1].id isa Integer
    @test storage.data[1].name isa String

    caches = create_cache_servers(server_count)
    @test length(caches) == server_count
    @test caches[1].id isa String
    @test length(keys(caches[1].bucket)) == 0

    table = consistent_hashing(caches, label_multiplier)
    @test length(keys(table.map)) == label_multiplier * server_count
    @test length(table.list) == label_multiplier * server_count


    # NOTE: Distributed Hashing should be fairly even =====================
    distribution_count = Dict()

    for record in rec
        hashed = hashing_oject(record.id)
        cache_id, angle = locate_cache(table, hashed)
        count = get(distribution_count, cache_id, 0)
        distribution_count[cache_id] = count + 1
        # NOTE: distribute data to cache-servers
        cache_idx = findfirst(x -> x.id == cache_id, caches)
        cache_svr = caches[cache_idx]
        push!(cache_svr.bucket, record.id => record)
    end

    println(json(distribution_count, 2))


    # NOTE: Construct and query
    system = construct_system(storage, caches, table)
    response = system.api__query(100)
    @test response isa ResponseMessage
    @test response.data != nothing
    @test response.message == SUCCESS

    response = system.api__query(101)
    @test response isa ResponseMessage
    @test response.data == nothing
    @test response.message == SYSTEM_ERROR

    response = system.api__query(-1)
    @test response isa ResponseMessage
    @test response.data == nothing
    @test response.message == NOT_FOUND

    response = system.api__cache_inspect(caches[1].id)
    @test response.message == SUCCESS
    bucket = response.data
    @test length(bucket) > 0

    @test length(system.storage.data) == 1000
    system.api__add_records(130)
    @test length(system.storage.data) == 1130
end


@testset "Plot utils" begin
    a = Point(0, 1)
    b = Point(1, 0)
    c = find_center(a, b)
    @test c.x == 0.5
    @test c.y == 0.5

    a = Point(0, 3)
    b = Point(4, 0)
    d = distance(a, b)
    @test d == 5
    c = find_center(a, b)
    @info "Circle-Center = $(c)"

    xes, yes = make_arc(a, b)
    @info "X-series = $([_ for _=xes])"
    @info "Y-series = $([_ for _=yes])"

    @test xes[1] == a.x
    @test yes[1] == a.y
end


# @testset "CLI command" begin
#     input_cmnd = "/add"
#     @test parse_command(input_cmnd) == ("add", nothing)

#     input_cmnd = "/a"
#     @test parse_command(input_cmnd) == ("a", nothing)

#     input_cmnd = "a"
#     @test parse_command(input_cmnd) == (nothing, nothing)

#     input_cmnd = ""
#     @test parse_command(input_cmnd) == (nothing, nothing)

#     input_cmnd = "/add 1"
#     @test parse_command(input_cmnd) == ("add", ["1"])
# end
