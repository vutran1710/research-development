# Type Aliases ==========================================
Angle = Float64
ServerID = String
RecordID = Integer

# Constants & Enum ======================================
@enum Message SUCCESS=1 NOT_FOUND SYSTEM_ERROR


# Structs representing System components ================
struct Record
    id::RecordID
    name::String
end

struct Bucket
    data::Dict{RecordID, Record}
end

struct CacheServer
    id::ServerID
    bucket::Bucket
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
    data::Record
    message::Message
end

# Combining everything to The-System =======================
struct TheSystem
    query::Any
end
