using Test
using JSON
using Logging
include("../src/structs.jl")
include("../src/consistent_hashing_ring.jl")
include("../src/cli.jl")

logger = SimpleLogger()
global_logger(logger)


@testset "consistent-hashing" begin
    # Test here
end
