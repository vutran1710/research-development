using Faker

LIMIT = 10000

name() = "$(Faker.first_name()) $(Faker.last_name())"

struct Record
    id::Integer
    name::String
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
