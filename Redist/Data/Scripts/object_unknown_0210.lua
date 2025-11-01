--- Best guess: Creates and positions an item (ID 377) randomly near an object if conditions are met, likely for spawning resources or loot.
function object_unknown_0210(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        var_0000 = get_object_quality(objectref)
        -- callis 003B, 0 (unmapped)
        -- TODO - these calls to get_schedule() cant possibly be right
        if var_0000 == get_schedule(1) then
            return
        end
        -- callis 003B, 0 (unmapped)
        var_0001 = set_item_quality(get_schedule(1), objectref)
        if random2(4, 1) > 1 then
            -- callis 0024, 1 (unmapped)
            var_0002 = create_new_object(377)
            if var_0002 then
                -- calli 0089, 2 (unmapped)
                set_item_flag(18, var_0002)
                -- calli 008A, 2 (unmapped)
                clear_item_flag(11, var_0002)
                set_object_frame(var_0002, 24)
                -- callis 0018, 1 (unmapped)
                var_0003 = get_object_position(objectref)
                var_0004 = aidx(var_0003, 1) - random2(1, 0)
                var_0005 = aidx(var_0003, 2) - random2(1, 0)
                var_0006 = aidx(var_0003, 3) + 1
                -- callis 0026, 1 (unmapped)
                var_0001 = update_last_created({var_0004, var_0005, var_0006})
            end
        end
    end
    return
end