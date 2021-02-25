# Type Aliases ==========================================
Angle = Float64
ServerID = String
RecordID = Integer

# Constants & Enum ======================================
@enum Message SUCCESS=1 NOT_FOUND SYSTEM_ERROR


# Structs representing System parts  ====================
struct Record
    id::RecordID
    name::String
end

struct CacheServer
    id::ServerID
    bucket::Dict{RecordID, Record}
end


struct PersistentStorage
    data::Array{Record}
end

struct ConsistentHashingTable
    map::Dict{Angle, ServerID}
    list::Array{Angle}
    server_map::Dict{ServerID, Array{Angle}}
end

struct ResponseMessage
    data::Union{Nothing, Record, Dict}
    message::Message
end

struct TheSystem
    api__query::Any
    api__cache_inspect::Any
    api__add_records::Any
    storage::PersistentStorage
    table::ConsistentHashingTable
end

struct Point
    x::Float64
    y::Float64
end
