--- Best guess: Simulates a roulette game, checking time and casino state to determine outcomes and trigger effects.
function object_unknown_0809(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 and not in_usecode(objectref) then
        close_gumps()
        var_0000 = utility_position_0828()
        var_0000 = utility_unknown_0826()
        if get_time_hour() >= 15 or get_time_hour() <= 3 then
            for var_0001 in ipairs(var_0000) do
                clear_item_flag(11, var_0003)
            end
            set_schedule_type(9, -232)
        end
        var_0004 = find_nearby_avatar(814)
        var_0005 = find_nearby_avatar(809)
        var_0006 = find_nearby_avatar(818)
        if #var_0006 > 0 or #var_0005 ~= 3 or #var_0004 < 1 then
            return
        end
        set_flag(31, false)
        set_flag(32, false)
        set_flag(33, false)
        utility_unknown_1075(0, "@Spin baby!@", -356)
        for var_0007 in ipairs(var_0005) do
            var_000A = random2(2, 0) * 8
            halt_scheduled(var_0009)
            var_000B = execute_usecode_array({1547, 8533, var_000A, -3, 7947, 29, 17496, 8014, 22, -3, 7947, 29, 17496, 7758}, var_0009)
        end
    end
end