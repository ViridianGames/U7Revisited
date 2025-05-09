--- Best guess: Adjusts sail states (type 199) on a mast, likely for ship navigation.
function func_0830(eventid, itemref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = eventid
    var_0001 = arg1
    if var_0000 == 1 then
        var_0002 = -4
        var_0003 = 88
        var_0004 = unknown_0035H(0, 25, 199, var_0001[1]) --- Guess: Sets NPC location
        var_0005 = add_container_items(var_0004, {0, 21, 7764})
    elseif var_0000 == 0 then
        var_0002 = 4
        var_0003 = 87
    end
    -- Guess: sloop adjusts sail states
    for i = 1, 5 do
        var_0008 = {6, 7, 8, 1, 27}[i]
        var_0009 = get_sail_state(var_0008) --- Guess: Gets sail state
        set_sail_state(var_0008, var_0009 + var_0002) --- Guess: Sets sail state
    end
    unknown_000FH(var_0003) --- Guess: Triggers event
end