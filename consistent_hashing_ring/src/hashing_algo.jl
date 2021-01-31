# include("components.jl")


function place_servers_over_ring(servers::Array{CacheServer})
    count = length(servers)
    deg_block = (2 / count)π
    place(idx) = [(idx - 1) * deg_block, servers[idx].id]
    map(place, 1:count)
end

function derive_labels(server_ring::Array, label_count::Integer)
    count = length(server_ring)
    deg_block = (2 / count)π
    step_deg = (2 / count / label_count)π
    distribute(s) = map(i -> [s[1] + i * count * step_deg, s[2]] , 1:label_count)
    map(distribute, server_ring)
end
