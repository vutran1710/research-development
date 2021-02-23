welcome = """
Type in command using one of the following:
======================================================
/add
    # add 10 random points to the hashing ring

/get {record_id}
    # get a specific record using its id
======================================================
"""


parse_command(str) = begin
    splitted = split(str, " ")
    len = length(splitted)

    if len == 0
        return nothing, nothing
    end

    cmd_str = splitted[1]
    invalid_cmd_str = !occursin("/", cmd_str) || length(cmd_str) < 2

    if invalid_cmd_str
        return nothing, nothing
    else
        cmd_str = cmd_str[2:length(cmd_str)]
    end

    args = len > 1 ? splitted[2:len] : nothing
    return cmd_str, args
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
    cmd_str, args = parse_command(readline())

    if cmd_str == nothing
        @error "Invalid Command!"
        return nothing
    end

    try
        caller = getfield(cli, Symbol(cmd_str))
        @info caller
    catch e
        @error "ControllerFunction does not exist"
        println("")
    end
end


struct CLIMaster
    add::Any
    get::Any
end
