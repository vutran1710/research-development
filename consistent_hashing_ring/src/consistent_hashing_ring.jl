module consistent_hashing_ring
using UUIDs: uuid1
using JSON

function distribute_caching_server_farm(server_count::Integer)
    # Setting distinct servers with unique ids
    server_ids = [uuid1() for _ in range(0, length=server_count)]
    # Distribute server-ids over the caching CIRCLE
    # Distribution is weightless (no weight-factor considered)
    # 360 degrees divided by number of servers
    deg_range = 360 / server_count
    # Each server-id will be assocciated with a degree-fragment
    # defined as [Lower-Degree; Lower-Degree + Deg-Range]
    plot_server(index) = [index * deg_range, string(server_ids[index+1])]
    server_ring = [plot_server(i) for i in range(0, length=server_count)]
    return server_ring
end

ring = distribute_caching_server_farm(5)
println(json(ring, 2))


# using DBInterface, MySQL

# host, usr, pwd, db = "localhost", "user", "123123123", "mydb"
# protocol = MySQL.API.MYSQL_PROTOCOL_TCP
# ports = [3300 + i for i in range(0, length=2)]
# println(ports)

# make_conn(port) = DBInterface.connect(
#     MySQL.Connection,
#     host, usr, pwd,
#     db=db, port=port, protocol=protocol,
# )

# conns = Dict(port => make_conn(port) for port in ports)
# sql_exec(conn, sql) = DBInterface.execute(conn::MySQL.Connection, sql)

# text_cur = sql_exec(conns[3300], "select 1 + 1;")
# println(text_cur)

end
