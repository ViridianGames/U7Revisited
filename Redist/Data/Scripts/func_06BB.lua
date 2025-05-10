--- Best guess: Applies effects to party members not matching a specific NPC ID (356) with non-zero dexterity, triggering a sequence when event ID 3 is received.
function func_06BB(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        var_0000 = unknown_0014H(objectref)
        var_0001 = unknown_0023H()
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            if var_0004 ~= 356 and not unknown_004AH(15, unknown_0020H(2, var_0004)) then
                unknown_005CH(var_0004)
                unknown_093FH(0, var_0004)
                unknown_004BH(7, var_0004)
                unknown_004CH(356, var_0004)
                var_0005 = unknown_0002H(var_0000, 1723, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        unknown_093FH(31, objectref)
    end
    return
end