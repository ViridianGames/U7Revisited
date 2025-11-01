--- Best guess: Applies effects to nearby items (type 359, within 40 units) not already affected when event ID 3 is triggered, likely part of a dungeon trap.
function utility_event_0444(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 3 then
        var_0000 = get_item_quality(objectref)
        if not var_0000 then
            var_0001 = find_nearby(8, 40, 359, objectref)
        else
            var_0001 = find_nearby(8, var_0000, 359, objectref)
        end
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            if not get_item_flag(6, var_0004) then
                utility_unknown_1087(0, var_0004)
                set_item_flag(1, var_0004)
            end
        end
    end
    return
end