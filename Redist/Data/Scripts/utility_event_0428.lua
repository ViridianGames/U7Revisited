--- Best guess: Applies effects to nearby items (within 5 units, type 753) and sets flag 599 when triggered by event ID 3, likely part of a dungeon trap or forge.
function utility_event_0428(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        var_0000 = find_nearby(0, 5, 753, objectref)
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            set_alignment(2, var_0003)
            set_schedule_type(0, var_0003)
            clear_item_flag(1, var_0003)
        end
        set_flag(599, true)
    end
    return
end