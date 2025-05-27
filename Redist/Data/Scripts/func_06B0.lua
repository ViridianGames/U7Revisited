--- Best guess: Applies a poison effect to party members when event ID 3 is triggered, if their strength is not zero, likely in a toxic area.
function func_06B0(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0023H()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not unknown_004AH(unknown_0020H(0, var_0003), unknown_0014H(objectref)) then
                unknown_0089H(8, get_npc_name(var_0003))
            end
        end
    end
    return
end