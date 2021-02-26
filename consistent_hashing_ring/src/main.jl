module main
include("structs.jl")
include("architech.jl")
# include("plotf.jl")
include("cli.jl")
using Logging
using JSON
# using Plots
# using Colors


logger = SimpleLogger()
global_logger(logger)

# pyplot()

# # ------------ setup
# color_generator = Iterators.Stateful(distinguishable_colors(cache_count))
# color_map = Dict(s.id => popfirst!(color_generator) for s ∈ caches)

# # ------------ plotting setups
# default(legendfontsize=16, framestyle=:zerolines, tickfont=(12, :white))
# plot(sin, cos, 0, 2π, aspect_ratio=1, show=true, label=false, size = (700, 700))

# # ------------ plotting servers
# for (server_id, angles) in hash_table.server_map
#     x_series, y_series = map(sin, angles), map(cos, angles)
#     color = color_map[server_id]

#     scatter!(
#         x_series,
#         y_series,
#         markersize=20,
#         label=server_id,
#         c=color,
#     )
# end


# # NOTE: keeping the plotting-window open until user provide some input
# pin_object(table::ConsistentHashingTable) = begin
#     for _ in 1:10
#         hashed = hashing_oject(rand(1:1000))
#         _, angle = locate_cache(table, hashed)

#         # NOTE: animation if possible, otherwise, fuck it!
#         # @gif for i ∈ hashed:(abs(angle-hashed)/10):angle
#         #     plot!([sin(i)], [cos(i)], c=:black, arrow=true, label=false, linewidth=3)
#         # end every 2

#         plot!(
#             [sin(hashed), sin(angle)],
#             [cos(hashed), cos(angle)],
#             arrow=1.5,
#             label=false,
#             c=:red,
#             linewidth=2,
#             linealpha=0.3,
#         )
#         sleep(0.1)
#     end
# end


# add_points = (_...) -> 1

# inspect_cache_bucket = params -> begin
#     cache_id = String(params)
#     the_system.cache_inspect(cache_id)
# end

# get_data = params -> begin
#     record_id = parse(Int64, params[1])
#     the_system.query(record_id)
# end

# compose(
#     run_forever,
#     handle_user_input,
#     CLIMaster,
# )(add_points, get_data, inspect_cache_bucket)

system = construct(10, 3, 5)
ClientCLI(
    "Get a single record by its ID",
    "get" => (system.api__get_record, Integer),
    "Add a number of records to Store",
    "add" => (system.api__add_records, Integer),
    "Inspect a cache's bucket by its cache-id",
    "bucket" => (system.inspect__cache_data, String),
)

end
