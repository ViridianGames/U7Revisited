--- Best guess: Triggers an effect on NPCs (94, 95) when approaching the Minoc mill, activated by event ID 3.
function func_06C9(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        var_0000 = {94, 95}
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            unknown_093FH(11, var_0003)
        end
    end
    return
end