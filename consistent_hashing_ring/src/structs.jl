@enum Message SUCCESS=1 NOT_FOUND SYSTEM_ERROR


struct Record
    id::Integer
    name::String
end

struct Bucket
    data::Dict{Integer, Record}
end

struct CacheServer
    id::String
    bucket::Bucket
end

struct PersistentStorage
    data::Array{Record}
end

struct ConsistentHashingTable
    map::Dict{Float64, String}
    list::Array{Float64}
    server_map::Dict{String, Array{Float64}}
end

struct TheSystem
    query::Any
end

struct ResponseMessage
    data::Record
    message::Message
end
