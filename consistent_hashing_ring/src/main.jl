module main
using UUIDs: uuid1, UUID
using JSON

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
function make_servers(number::Integer)
    map(Server, 1:number)
end

function distribute(servers::Array{Server})
    count = length(servers)
    # Distribute server-ids over the caching CIRCLE
    # Distribution is weightless (no weight-factor considered)
    # 360 degrees divided by number of servers
    deg_range = 360 / count
    # Each server-id will be assocciated with a degree-fragment
    # defined as [Lower-Degree; Lower-Degree + Deg-Range]
    plot_server(idx) = [(idx-1) * deg_range, servers[idx].id]
    ring = map(plot_server, 1:count)
    return ring
end

servers = make_servers(5)
ring = distribute(servers)
println(json(ring, 2))

end
