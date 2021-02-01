module main
include("components.jl")
include("hashing_algo.jl")

using JSON
using Plots
using Colors

pyplot()

# ----------- config
server_count = 5
label_count = 8
record_count = 100

# ----------- setup
storage = PersistentStorage(record_count)
servers = map(CacheServer, 1:server_count)
ring = place_servers_over_ring(servers)
labels = derive_labels(ring, label_count)
println(json(labels, 2))
color_generator = Iterators.Stateful(distinguishable_colors(server_count))

# # ----------- plotting setup
default(legendfontsize=16, framestyle=:zerolines, tickfont=(12, :white))
plot(sin, cos, 0, 2π, aspect_ratio=1, show=true, label=false)

# # ----------- plotting servers
for group in labels
    x_series, y_series = [], []
    label = group[1][2]

    for point in group
        angle = point[1]
        push!(x_series, sin(angle))
        push!(y_series, cos(angle))
    end

    scatter!(
        x_series,
        y_series,
        markersize=20,
        label=label,
        c=popfirst!(color_generator),
    )

end

# # NOTE: keeping the plotting-window open until user provide some input
readline()

end
