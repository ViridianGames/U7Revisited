--- Best guess: Updates item position based on quality and predefined arrays, tied to environmental effects.
function utility_position_0803(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = objectref
    var_0001 = {2879, 2919, 567, 2175, 1023, 1855, 519, 261, 1231}
    var_0002 = {1810, 2402, 1609, 2338, 2435, 402, 491, 2826, 1314}
    var_0003 = {0, 2, 0, 0, 1, 0, 0, 0, 0}
    var_0004 = get_object_quality(var_0000) + 1 --- Guess: Gets item quality
    if not get_flag(308) and var_0004 == 8 then
        var_0004 = 9
    end
    var_0005 = {var_0001[var_0004], var_0002[var_0004], var_0003[var_0004]}
    return var_0005
end