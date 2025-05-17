--- Best guess: Creates and positions an item (ID 377) randomly near an object if conditions are met, likely for spawning resources or loot.
function func_00D2(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        var_0000 = get_object_quality(objectref)
        -- callis 003B, 0 (unmapped)
        if var_0000 == get_schedule() then
            return
        end
        -- callis 003B, 0 (unmapped)
        var_0001 = unknown_0015H(get_schedule(), objectref)
        if random2(4, 1) > 1 then
            -- callis 0024, 1 (unmapped)
            var_0002 = unknown_0024H(377)
            if var_0002 then
                -- calli 0089, 2 (unmapped)
                unknown_0089H(18, var_0002)
                -- calli 008A, 2 (unmapped)
                unknown_008AH(11, var_0002)
                set_object_frame(var_0002, 24)
                -- callis 0018, 1 (unmapped)
                var_0003 = unknown_0018H(objectref)
                var_0004 = aidx(var_0003, 1) - random2(1, 0)
                var_0005 = aidx(var_0003, 2) - random2(1, 0)
                var_0006 = aidx(var_0003, 3) + 1
                -- callis 0026, 1 (unmapped)
                var_0001 = unknown_0026H({var_0004, var_0005, var_0006})
            end
        end
    end
    return
end