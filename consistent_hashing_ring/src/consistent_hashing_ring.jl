module consistent_hashing_ring
using DBInterface, MySQL

host, usr, pwd, db = "localhost", "user", "123123123", "mydb"
protocol = MySQL.API.MYSQL_PROTOCOL_TCP
ports = [3300 + i for i in range(0, length=2)]
println(ports)

make_conn(port) = DBInterface.connect(
    MySQL.Connection,
    host, usr, pwd,
    db=db, port=port, protocol=protocol,
)

conns = Dict(port => make_conn(port) for port in ports)
sql_exec(conn, sql) = DBInterface.execute(conn::MySQL.Connection, sql)

text_cur = sql_exec(conns[3300], "select 1 + 1;")
println(text_cur)

end
