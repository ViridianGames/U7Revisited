--- Best guess: Manages a rat race game, checking game objects (IDs 763, 764) and assigning random states to items (ID 644) based on time and position.
function utility_clock_0815()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E, var_001F, var_0020

    var_0000 = find_nearby_avatar(763)
    var_0001 = find_nearby_avatar(764)
    if #var_0001 == 4 and #var_0000 == 2 then
        var_0002 = random2(4, 1)
        var_0003 = get_object_position(var_0000[1])
        var_0004 = find_nearby(0, 10, 644, var_0000[1])
        var_0005 = get_object_position(objectref)
        if get_time_hour() >= 15 or get_time_hour() <= 3 then
            for var_0006 in ipairs(var_0004) do
                var_0009 = get_object_position(var_0008)
                if var_0009[1] <= var_0003[1] and var_0009[1] >= var_0003[1] - 5 and var_0009[2] <= var_0003[2] + 8 and var_0009[2] >= var_0003[2] - 8 then
                    clear_item_flag(var_0008, 11)
                end
            end
        end
        var_000A = {1548, 7765}
        var_000B = {var_000A, 28, -1, 17419, 8013, 2, 7975, 0, 7750}
        var_000C = {var_000A, 1, 7975, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        var_000D = {var_000A, 14, -1, 17419, 8013, 1, 7975, 15, -1, 17419, 8013, 0, 7750}
        var_000E = {var_000A, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        var_000F = {var_000A, 2, 7975, 28, -1, 17419, 8013, 0, 7750}
        var_0010 = {var_000B, 2, 7719}
        var_0011 = {var_000A, 14, -4, 17419, 8013, 2, 17447, 8013, 0, 7750}
        var_0012 = {var_000A, 14, -1, 17419, 8013, 7, 7975, 15, -1, 17419, 8013, 0, 7750}
        var_0013 = {var_000C, 1, 7719}
        var_0014 = {var_000D, 1, 7719}
        var_0015 = {var_000E, 1, 7719}
        var_0016 = {var_000F, 1, 7719}
        var_0017 = {var_000A, 2, -1, 17419, 8014, 2, -1, 17419, 8016, 1, 7975, 28, -1, 17419, 8013, 1, 7975, 0, 7750}
        var_0018 = 0
        for var_0019 in ipairs(var_0001) do
            var_0018 = var_0018 + 1
            if var_0002 == var_0018 then
                var_001C = random2(3, 1)
                if var_001C == 1 then
                    var_001D = var_000B
                elseif var_001C == 2 then
                    var_001D = var_000C
                elseif var_001C == 3 then
                    var_001D = var_000D
                elseif var_001C == 4 then
                    var_001D = var_000E
                elseif var_001C == 5 then
                    var_001D = var_000F
                end
            elseif random2(8, 1) == 1 then
                var_001D = var_0010
            elseif random2(8, 1) == 2 then
                var_001D = var_0011
            elseif random2(8, 1) == 3 then
                var_001D = var_0012
            elseif random2(8, 1) == 4 then
                var_001D = var_0013
            elseif random2(8, 1) == 5 then
                var_001D = var_0014
            elseif random2(8, 1) == 6 then
                var_001D = var_0015
            elseif random2(8, 1) == 7 then
                var_001D = var_0016
            elseif random2(8, 1) == 8 then
                var_001D = var_0017
            end
            halt_scheduled(var_001B)
            var_001F = execute_usecode_array(var_001B, var_001D)
        end
    end
end