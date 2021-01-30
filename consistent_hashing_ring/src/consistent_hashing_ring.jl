module main
using UUIDs: uuid1, UUID
using JSON
using Plots
using Colors

pyplot()


# MODELS ===============================================================
mutable struct Bucket
    data::Any
end

struct Server
    id::String
    bucket::Bucket
    Server(_...) = new(string(uuid1())[end-5:end])
end


# SETUP ===============================================================
make_servers(count) = map(Server, 1:count)

function place_servers_over_ring(servers::Array{Server})
    count = length(servers)
    deg_block = 360 / count
    place(idx) = [(idx - 1) * deg_block, servers[idx].id]
    map(place, 1:count)
end

function derive_labels(server_ring::Array, label_count::Integer)
    count = length(server_ring)
    deg_block = 360 / count
    step_deg = 360 / count / label_count
    distribute(s) = map(i -> [s[1] + i * step_deg, s[2]] , 1:label_count)
    map(distribute, server_ring)
end


# RUNNING ==============================================================
# ----------- config
server_count = 3
label_count = 1

# ----------- setup
servers = make_servers(3)
ring = place_servers_over_ring(servers)
labels = derive_labels(ring, label_count)
color_generator = Iterators.Stateful(distinguishable_colors(server_count))

# ----------- plotting setup
default(legendfontsize = 16, framestyle = :zerolines)
plot(sin, cos, 0, 2π, aspect_ratio=1, show=true, alpha=0.6)

# ----------- plotting servers
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
        markersize=16,
        label=label,
        c=popfirst!(color_generator),
        alpha=0.7,
    )

end

# NOTE: keeping the plotting-window open until user provide some input
readline()

end
