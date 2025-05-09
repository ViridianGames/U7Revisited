--- Best guess: Applies effects to party members when event ID 3 is triggered and flag 5 is not set, based on item quality, likely in a dungeon trap.
function func_06CC(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        if get_flag(5) == 0 then
            var_0000 = unknown_0014H(itemref)
            var_0001 = unknown_0023H()
            for i = 1, #var_0001 do
                var_0004 = var_0001[i]
                if not unknown_0072H(359, 638, 9, var_0004) then
                    if var_0000 == 30 then
                        var_0005 = 30
                    else
                        var_0005 = unknown_0010H(var_0000, 1)
                    end
                    unknown_0071H(5, var_0005, var_0004)
                end
            end
        end
    end
    return
end