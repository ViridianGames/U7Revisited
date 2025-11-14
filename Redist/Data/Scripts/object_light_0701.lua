--- Best guess: Manages a lit torch's interaction, calling external functions to update its state or trigger effects, possibly for lighting or environmental changes.
function object_light_0701(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        -- call [0000] (0839H, unmapped)
        utility_event_0825(595, objectref)
    elseif eventid == 7 then
        -- call [0001] (0827H, unmapped)
        var_0000 = utility_unknown_0807(objectref, 356)
        var_0001 = execute_usecode_array(356, {17505, 17514, 8449, var_0000, 7769})
        -- call [0000] (0839H, unmapped)
        utility_event_0825(595, objectref)
    elseif eventid == 5 then
        -- call [0002] (0905H, unmapped)
        utility_unknown_1029(objectref)
    end
    return
end