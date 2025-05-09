--- Best guess: Triggers an effect for a specific item when used, checking ownership to ensure valid interaction.
function func_0369(eventid, itemref)
    local var_0000

    if eventid == 1 then
        var_0000 = unknown_006EH(itemref)
        if var_0000 then
            unknown_080AH(873, itemref)
        end
    end
end