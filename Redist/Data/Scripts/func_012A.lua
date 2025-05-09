--- Best guess: Manages the Ring of Regeneration, applying health regeneration to an NPC when equipped or used, with periodic checks and random item removal.
function func_012A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 5 then
        var_0000 = unknown_006EH(itemref)
        if var_0000 and unknown_0031H(var_0000) then
            unknown_005CH(itemref)
            unknown_0002H(itemref, {100, 298, 7765})
        else
            unknown_006AH(0)
        end
    elseif eventid == 6 then
        unknown_005CH(itemref)
    elseif eventid == 2 then
        unknown_005CH(itemref)
        var_0000 = unknown_006EH(itemref)
        if var_0000 and unknown_0031H(var_0000) then
            var_0002 = unknown_0020H(0, var_0000)
            var_0003 = unknown_0020H(3, var_0000)
            if var_0003 < var_0002 then
                var_0001 = unknown_0021H(1, 3, var_0000)
                if math.random(1, 100) == 1 then
                    unknown_006FH(itemref)
                end
            end
            unknown_0002H(itemref, {100, 298, 7765})
        end
    end
    return
end