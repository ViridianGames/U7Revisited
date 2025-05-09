--- Best guess: Randomly applies an effect to a party member when event ID 3 is triggered, based on item quality and a random selection.
function func_06B4(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0023H()
        var_0001 = unknown_092BH(var_0000)
        var_0002 = unknown_0010H(var_0001, 1)
        var_0003 = unknown_0010H(unknown_0014H(itemref), 1)
        unknown_0936H(unknown_001BH(var_0000[var_0002]), var_0003)
    end
    return
end