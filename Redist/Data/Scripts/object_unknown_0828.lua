--- Best guess: Triggers an action for an item with quality 0 when event ID is not 1, likely for a specific item interaction.
function object_unknown_0828(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        if get_object_quality(objectref) == 0 then
            var_0000 = utility_unknown_0799(objectref)
        end
    end
    return
end