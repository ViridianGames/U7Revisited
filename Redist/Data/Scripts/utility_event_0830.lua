--- Best guess: Manages a winch mechanic, handling events to raise/lower objects (via 0828H) and checking for blockers (via 080EH), with quality-based filtering.
function utility_event_0830(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if P0 == 1 then
        if in_usecode(P1) then
            abort()
        end
        utility_position_0808(7, P1, 1585, -1, {-2, -2}, P1)
    elseif P0 == 2 then
        var_0002 = get_object_quality(objectref)
        var_0003 = find_nearby(0, 15, 870, objectref)
        var_0004 = find_nearby(0, 15, 515, objectref)
        table.insert(var_0003, var_0004)
        var_0004 = {}
        for var_0005 in ipairs(var_0003) do
            if get_object_quality(var_0007) == var_0002 then
                table.insert(var_0004, var_0007)
            end
        end
        if utility_unknown_0782(0, var_0004) then
            var_0008 = execute_usecode_array(objectref, {4, -1, 17419, 8014, 1, 7750})
        elseif not get_flag(61) then
            return false
        else
            utility_unknown_0820()
        end
    end
end