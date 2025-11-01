--- Best guess: Applies an effect to nearby items (type 494, within 99 units) based on their state when event ID 3 is triggered, likely in a dungeon.
function utility_event_0448(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 3 then
        var_0000 = find_nearby(0, 99, 494, objectref)
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            var_0004 = get_schedule_type(var_0003)
            if var_0004 ~= 0 then
                utility_unknown_1087(0, var_0003)
            end
        end
    end
    return
end