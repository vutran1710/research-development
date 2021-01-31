using Faker

LIMIT = 10000

name() = "$(Faker.first_name()) $(Faker.last_name())"

struct Record
    id::Integer
    name::String
    Record(id) = new(id, name())
end

struct PersistentStorage
    data::Array{Record}
    PersistentStorage(record_count::Integer) = begin
        @assert record_count < LIMIT
        gen_ids = 1:LIMIT
        ids= map(x -> rand(gen_ids), 1:record_count)
        data = map(Record, 1:record_count)
        new(data)
    end
end
