--- Best guess: Manages a complex dungeon sequence, checking flags and applying effects to items (types 867, 338, 810, 912) and NPCs (167, 177) based on timers and conditions.
function utility_clock_0449(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010

    if eventid == 3 then
        if get_flag(343) and not get_flag(404) then
            remove_npc(246)
            var_0000 = find_nearby(0, 15, 867, objectref)
            var_0001 = find_nearby(0, 15, 338, objectref)
            var_0002 = find_nearby(0, 15, 810, objectref)
            var_0003 = find_nearby(176, 15, 912, objectref)
            var_0004 = {var_0000, var_0001, var_0002, var_0003}
            for i = 1, #var_0004 do
                var_0007 = var_0004[i]
                var_0008 = get_item_shape(var_0007)
                var_0009 = get_object_position(var_0007)
                if var_0009[3] == 6 then
                    if var_0008 == 867 or var_0008 == 912 then
                        var_000A = {1, var_0009[2], var_0009[1]}
                    else
                        var_000A = {0, var_0009[2], var_0009[1]}
                    end
                    var_000B = set_last_created(var_0007)
                    if not var_000B then
                        var_000B = update_last_created(var_000A)
                    end
                end
            end
            var_000C = find_nearby(0, 40, 400, objectref)
            var_000C = var_000C[find_nearby(0, 40, 414, objectref)]
            for i = 1, #var_000C do
                var_000F = var_000C[i]
                if get_object_quality(var_000F) == 1 and get_item_quantity(var_000F, 1) == 118 then
                    remove_item(var_000F)
                end
            end
            set_flag(404, true)
            set_timer(6)
        elseif not get_flag(343) then
            var_0010 = get_timer(6)
            if var_0010 >= 24 then
                utility_event_0783()
                remove_item(objectref)
            end
        end
    end
    return
end