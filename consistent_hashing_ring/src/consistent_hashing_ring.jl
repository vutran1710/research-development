module main
using UUIDs: uuid1, UUID
using JSON
using Plots

pyplot()


# MODELS ===============================================================
mutable struct Bucket
    data::Any
end

struct Server
    id::String
    bucket::Bucket
    Server(_...) = new(string(uuid1()))
end


# SETUP ===============================================================
make_servers(count) = map(Server, 1:count)

function place_servers_over_ring(servers::Array{Server})
    """
    Each server-id will be assocciated with a degree-anchor
    defined as [anchor-degree; server]
    """
    count = length(servers)
    deg_block = 360 / count
    place(idx) = [(idx - 1) * deg_block, servers[idx].id]
    map(place, 1:count)
end

function derive_labels(server_ring::Array, label_count::Integer)
    count = length(server_ring)
    deg_block = 360 / count
    step_deg = deg_block * 4 / 3
    distribute(s) = map(i -> [s[1] + i * step_deg, s[2]] , 1:label_count)
    map(distribute, server_ring)
end


servers = make_servers(5)
println(length(servers))

ring = place_servers_over_ring(servers)
println(json(ring, 2))
@assert length(ring) == 5

labels = derive_labels(ring, 10)
println(json(labels, 2))
@assert length(labels) == 5

# # Plotting
colors = [:blue, :orange, :green, :red, :black, :yellow]
color_idx = 1

for group in labels
    x_series = []
    y_series = []
    label = ""

    global color_idx
    color = colors[color_idx]

    for point in group
        angle = point[1]
        label = point[2]
        push!(x_series, sin(angle))
        push!(y_series, cos(angle))
    end

    display(scatter!(x_series, y_series, markersize=12, label=label, c=color))

    color_idx += 1

end

readline()

end
