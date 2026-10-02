--- Best guess: Spawns items or objects based on item quality, likely for dynamic environmental or quest interactions, with specific coordinates and types.
function object_unknown_0410(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        close_gumps()
        var_0000 = find_nearby(0, 10, 411, objectref)
        var_0001 = get_object_quality(objectref)
        if var_0001 == 0 or var_0001 > 3 then
            var_0002 = execute_usecode_array(objectref, {76, 8024, 37, 8024, 1, 8006, 0, 7750})
        else
            var_0003 = {915, 916, 914}
            var_0004 = var_0003[var_0001]
            var_0002 = execute_usecode_array(objectref, {7, -10, 7947, 4, 3, -4, 7948, 8, 17496, 17409, 8013, 0, 7750})
            var_0002 = execute_usecode_array(var_0000, {24, -7, 7947, 1549, 8021, 15, 17496, 17409, 8014, 0, 7750})
        end
    end
    return
end