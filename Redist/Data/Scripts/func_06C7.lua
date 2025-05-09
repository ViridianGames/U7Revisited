--- Best guess: Applies an effect to specific NPCs (90, 82, 81, 91, 93) when event ID 3 is triggered, likely part of a dungeon sequence.
function func_06C7(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        var_0000 = {90, 82, 81, 91, 93}
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            unknown_093FH(11, var_0003)
        end
    end
    return
end