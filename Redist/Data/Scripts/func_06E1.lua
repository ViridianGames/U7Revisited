--- Best guess: Counts active flags (3, 4, 5, 301, 308, 322, 353, 493, 609) and triggers an effect based on the count when event ID 3 is received, likely a dungeon or quest trigger.
function func_06E1(eventid, objectref)
    local var_0000, var_0001

    if eventid == 3 then
        if objectref == 0 then
            var_0000 = {2892, 1420}
        else
            var_0000 = unknown_0018H(objectref)
        end
        var_0001 = 0
        if not get_flag(493) then var_0001 = var_0001 + 1 end
        if not get_flag(308) then var_0001 = var_0001 + 1 end
        if not get_flag(482) then var_0001 = var_0001 + 1 end
        if not get_flag(599) then var_0001 = var_0001 + 1 end
        if not get_flag(481) then var_0001 = var_0001 + 1 end
        if not get_flag(3) then var_0001 = var_0001 + 1 end
        if not get_flag(301) then var_0001 = var_0001 + 1 end
        if not get_flag(4) then var_0001 = var_0001 + 1 end
        if not get_flag(5) then var_0001 = var_0001 + 1 end
        unknown_0063H(var_0001, var_0000)
    end
    return
end