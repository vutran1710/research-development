module consistent_hashing_ring
using DBInterface, MySQL

host, usr, pwd, db = "localhost", "user", "123123123", "mydb"
protocol = MySQL.API.MYSQL_PROTOCOL_TCP
ports = [3300 + i for i in range(0, length=2)]
println(ports)

make_conn(port) = DBInterface.connect(MySQL.Connection, host, usr, pwd, db=db, port=port, protocol=protocol)
DSS = Dict(i => make_conn(ports[i]) for i in range(1, length=length(ports)))

db_exec(conn, sql) = println(DBInterface.execute(conn::MySQL.Connection, sql))
db_exec(DSS[1], "select 1 + 1;")

end
