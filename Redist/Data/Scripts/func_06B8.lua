--- Best guess: Applies effects to party members with non-zero strength when event ID 3 is triggered, potentially paralyzing them and triggering a sequence.
function func_06B8(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 3 then
        var_0000 = unknown_0023H()
        var_0001 = unknown_0014H(objectref)
        for i = 1, #var_0000 do
            var_0004 = var_0000[i]
            var_0005 = unknown_0020H(0, var_0004)
            if not unknown_004AH(15, var_0005) then
                var_0006 = get_npc_name(var_0004)
                unknown_0620H(var_0006)
                var_0007 = unknown_0002H(var_0001, 1567, {7765}, var_0006)
                unknown_005CH(var_0004)
                unknown_093FH(4, var_0004)
                var_0007 = unknown_0002H(var_0001, 1720, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        unknown_093FH(31, objectref)
    end
    return
end