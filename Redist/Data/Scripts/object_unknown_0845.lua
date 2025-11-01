--- Best guess: Triggers an action for an item with quality 0 when event ID is not 1, likely for another specific item interaction.
function object_unknown_0845(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        if get_item_quality(objectref) == 0 then
            var_0000 = utility_unknown_0800(objectref)
        end
    end
    return
end