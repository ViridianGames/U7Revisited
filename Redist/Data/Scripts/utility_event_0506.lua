--- Best guess: Displays dialogue based on item types (275, 721, 989) when triggered, likely indicating environmental events like tremors or instability.
function utility_event_0506(eventid, objectref)
    if get_item_shape(objectref) == 275 then
        utility_unknown_1023("@It would seem the nearby island is not at all stable.@")
    elseif get_item_shape(objectref) == 721 or get_item_shape(objectref) == 989 then
        utility_unknown_1023("@All is not right in Britannia. Perhaps Lord British will know the reason behind this tremor.@")
    end
    return
end