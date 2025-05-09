--- Best guess: Triggers an action for an item with quality 0 when event ID is not 1, likely for another specific item interaction.
function func_034D(eventid, itemref)
    local var_0000

    if eventid ~= 1 then
        if unknown_0014H(itemref) == 0 then
            var_0000 = unknown_0820H(itemref)
        end
    end
    return
end