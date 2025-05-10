--- Best guess: Triggers an effect for a specific item when used, checking ownership to ensure valid interaction.
function func_0369(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = unknown_006EH(objectref)
        if var_0000 then
            unknown_080AH(873, objectref)
        end
    end
end