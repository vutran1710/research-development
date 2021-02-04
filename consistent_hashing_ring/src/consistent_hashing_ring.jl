module main
include("structs.jl")
include("architech.jl")

using JSON
using Plots
using Colors

pyplot()

# ------------ config
label_multiplier = 5
cache_count = 3
record_count = 100

# ------------ setup
rec = create_records(record_count)
store = PersistentStorage(rec)
caches = create_cache_servers(cache_count)
ch_table = consistent_hashing(caches, label_multiplier)
color_generator = Iterators.Stateful(distinguishable_colors(cache_count))
color_map = Dict(s.id => popfirst!(color_generator) for s ∈ caches)

# ------------ plotting setups
default(legendfontsize=16, framestyle=:zerolines, tickfont=(12, :white))
plot(sin, cos, 0, 2π, aspect_ratio=1, show=true, label=false, reuse=true)

# ------------ plotting servers
for (server_id, angles) in ch_table.server_map
    x_series, y_series = map(sin, angles), map(cos, angles)
    color = color_map[server_id]

    scatter!(
        x_series,
        y_series,
        markersize=20,
        label=server_id,
        c=color,
    )
end

# NOTE: keeping the plotting-window open until user provide some input
pin_object(table::ConsistentHashingTable) = begin
    for sample_id in 1:50
        hashed = hashing_oject(sample_id)
        _, angle = locate_cache(table, hashed)
        plot!(
            [sin(hashed), sin(angle)],
            [cos(hashed), cos(angle)],
            arrow=true,
            label=false,
            c=:black,
        )
        readline()
    end
end

while true
    command = readline()
    if command == "add"
        pin_object(ch_table)
    end
end


end
