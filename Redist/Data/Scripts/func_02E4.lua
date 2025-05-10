--- Best guess: Repositions container items (shape 810) and spawns a new object (ID 470) if empty, likely for a puzzle or trap.
function func_02E4(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_container_objects(0, 359, 810, 356)
    if not var_0000 then
        var_0001 = {-5, -5}
        var_0002 = {-1, -1}
        var_0003 = unknown_000EH(5, 470, objectref)
        if not var_0003 then
            -- call [0000] (0828H, unmapped)
            unknown_0828H(9, var_0000, 810, 0, var_0002, var_0001, var_0003)
        end
    end
    return
end