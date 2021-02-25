welcome = """
Type in command using one of the following:
======================================================
/add
    # add 10 random points to the hashing ring

/get {record_id}
    # get a specific record using its id

/bucket {cache_id}
    # listing all records in a specific cache's bucket
======================================================
"""


struct CLIMaster
    add::Any
    get::Any
    bucket::Any
end


run_forever(exec, before_cb=nothing, after_cb=nothing, delay::Int=0) = begin
    print(welcome)

    while true
        if before_cb != nothing
            before_cb()
        end

        result = exec()

        if after_cb != nothing
            after_cb(result)
        end

        sleep(delay)
    end
end


handle_user_input = cli -> () ->  begin
    print("command_input /")
    str = readline()
    splitted = split(str, " ")
    len = length(splitted)

    if len == 0
        return nothing, nothing
    end

    cmd = Symbol(splitted[1])

    if !hasproperty(cli, cmd)
        @error "Invalid Command!"
        return nothing
    end

    args = len > 1 ? splitted[2:end] : []

    try
        println("~~~~~~~~~~~~~~~~~~~~~~ BEGIN")
        caller = getfield(cli, cmd)
        @info caller(args...)
        println("~~~~~~~~~~~~~~~~~~~~~~ END")
    catch e
        @error "HandlerError > $(e)"
    end

    for _ in 1:3
        # NOTE: separator between commands
        println("")
    end
end
