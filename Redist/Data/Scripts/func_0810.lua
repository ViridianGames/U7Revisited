--- Best guess: Manages a cube puzzle, spawning floors (type 368 or 369) based on egg proximity.
function func_0810(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    var_0000 = objectref
    if arg1 == 0 then
        var_0001 = 368
        var_0002 = 8
    else
        var_0001 = 369
        var_0002 = 5
    end
    var_0003 = unknown_0018H(objectref) --- Guess: Gets position data
    var_0003 = create_array(get_object_quality(objectref), 6, var_0003) --- Guess: Creates array
    var_0004 = unknown_0035H(16, 80, 275, var_0003) --- Guess: Sets NPC location
    var_0005 = 0
    -- Guess: sloop manages floor spawning near eggs
    for i = 1, 5 do
        var_0008 = {6, 7, 8, 4, 155}[i]
        var_0005 = var_0005 + 1
        var_0003 = unknown_0018H(var_0008) --- Guess: Gets position data
        var_0009 = unknown_0035H(0, 1, var_0001, var_0003) --- Guess: Sets NPC location
        if var_0000 == 1 then
            if var_0009 then
                var_000A = unknown_0025H(var_0009) --- Guess: Checks position
                unknown_0026H(358) --- Guess: Updates position
                unknown_000FH(10) --- Guess: Triggers event
            end
        else
            if var_0009 == 0 then
                var_000B = get_object_status(var_0001) --- Guess: Gets item status
                set_object_frame(var_000B, var_0002) --- Guess: Sets item frame
                var_000A = unknown_0026H(var_0003) --- Guess: Updates position
                var_000A = unknown_0025H(var_0009) --- Guess: Checks position
                unknown_0026H(358) --- Guess: Updates position
                unknown_000FH(83) --- Guess: Triggers event
            end
        end
    end
end