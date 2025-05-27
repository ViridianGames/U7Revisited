--- Best guess: Applies a sleep effect to party members in a poppy field when event ID 3 is triggered, if their strength is not zero.
function func_06AF(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        unknown_000FH(28)
        var_0000 = unknown_0023H()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not unknown_004AH(unknown_0020H(0, var_0003), unknown_0014H(objectref)) then
                var_0004 = get_npc_name(var_0003)
                unknown_0620H(var_0004)
                unknown_0089H(1, var_0004)
                var_0005 = unknown_0002H(100, 1567, {17493, 7715}, var_0004)
            end
        end
    end
    return
end