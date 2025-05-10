--- Best guess: Triggers an action for an item with quality 0 when event ID is not 1, likely for a specific item interaction.
function func_033C(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        if unknown_0014H(objectref) == 0 then
            var_0000 = unknown_081FH(objectref)
        end
    end
    return
end