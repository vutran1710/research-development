using UUIDs: uuid1, UUID
using Faker

LIMIT = 10000

name() = "$(Faker.first_name()) $(Faker.last_name())"

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
    CacheServer(_...) = new(string(uuid1())[end-5:end])
end


struct PersistentStorage
    data::Array{Record}
    PersistentStorage(record_count::Integer) = begin
        @assert record_count < LIMIT
        gen_ids = 1:LIMIT
        create_record = _ -> Record(rand(gen_ids), name())
        data = map(create_record, 1:record_count)
        new(data)
    end
end


struct RequestHandler
    cache::Array{CacheServer}
    storage::PersistentStorage
end
