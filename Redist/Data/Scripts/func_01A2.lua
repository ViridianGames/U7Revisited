--- Best guess: Spawns ammo (ID 581) near giant bones at a specific time, likely for a timed resource generation mechanic.
function func_01A2(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = get_object_quality(objectref)
        if var_0000 ~= get_time_hour() then
            var_0001 = check_flag_location(0, 581, 5, objectref)
            if not var_0001 then
                -- callis 0024, 1 (unmapped)
                var_0002 = unknown_0024H(581)
                if var_0002 then
                    -- calli 0089, 2 (unmapped)
                    unknown_0089H(18, var_0002)
                    unknown_0089H(11, var_0002)
                    -- callis 0017, 2 (unmapped)
                    var_0003 = unknown_0017H(random2(100, 1), var_0002)
                    -- callis 0018, 1 (unmapped)
                    var_0004 = unknown_0018H(objectref)
                    -- callis 0026, 1 (unmapped)
                    var_0003 = unknown_0026H({aidx(var_0004, 1) + 1, aidx(var_0004, 2), aidx(var_0004, 3)})
                    if not var_0003 then
                        var_0003 = unknown_0015H(get_time_hour(), objectref)
                    end
                end
            end
        end
    end
    return
end