module main
using Logging
using JSON
using TypedTables
using PrettyPrinting
using UUIDs: uuid1
using Faker: first_name, last_name
using SplitApplyCombine: group
using Colors

include("structs.jl")
include("architech.jl")
include("plotf.jl")
# include("cli.jl")


logger = SimpleLogger()
global_logger(logger)


# ClientCLI(
#     "Re-construct a new System",
#     "new" => (new_system, [Integer, Integer, Integer]),
#     "Get a single record by its ID",
#     "get" => (system.api__get_record, Integer),
#     "Add a number of records to Store",
#     "add" => (system.api__add_records, Integer),
#     "Inspect a cache's bucket by its cache-id",
#     "bucket" => (get_bucket, String),
# )

system = construct(10, 4, 20)
@info system.api__get_record(2)
@info system.api__add_records(4)
@info system.api__get_record(2)

end
