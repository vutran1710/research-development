struct Record
    id::Integer
    name::String
end

mutable struct Bucket
    data::Array{Record}
end

struct CacheServer
    id::String
    bucket::Bucket
end

struct PersistentStorage
    data::Array{Record}
end

struct RequestHandler
    cache::Dict{String, CacheServer}
    storage::PersistentStorage
end

struct ConsistentHashingTable
    map::Dict{Float64, String}
    list::Array{Float64}
end
