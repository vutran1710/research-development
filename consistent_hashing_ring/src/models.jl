using UUIDs: uuid1, UUID


mutable struct Bucket
    data::Any
end

struct Server
    id::String
    bucket::Bucket
    Server(_...) = new(string(uuid1())[end-5:end])
end
