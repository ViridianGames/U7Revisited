--- Best guess: Manages a racing game mechanic, likely a horse race, checking lane outcomes, updating item frames, and awarding wins based on position comparisons, with NPC dialogue for results.
function func_060C(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017

    if unknown_001CH(232) == 9 then
        unknown_001DH(10, 232)
    end

    if not npc_in_party(232) then
        var_0000 = unknown_0035H(0, 50, 764, -356)
        for var_0003 in ipairs(var_0000) do
            get_object_frame(var_0003, 0)
            unknown_005CH(var_0003)
        end
    else
        var_0004 = unknown_0035H(0, 7, 644, itemref)
        var_0005 = unknown_0018H(itemref)
        var_0006 = 0
        var_0007 = unknown_0030H(763)
        for var_000A in ipairs(var_0004) do
            if get_object_frame(var_000A) == 1 or get_object_frame(var_000A) == 2 then
                var_0006 = var_000A
            end
        end
        var_0000 = unknown_0030H(763)
        var_000B = unknown_0018H(var_0006)[1]
        if not get_flag(6) then
            var_000C = 6
        else
            var_000C = 3
        end
        var_000D = unknown_0001H(var_0006, {73=8024, 74=8006, 73=7750})
        if get_flag(34) == false then
            set_flag(34, true)
            for var_0010 in ipairs(var_0004) do
                var_0011 = unknown_0018H(var_0010)
                if var_0011[1] <= var_000B and var_0011[1] >= var_000B - 5 and var_0011[2] + 8 <= var_0005[2] and var_0011[2] - 8 >= var_0005[2] then
                    if var_0011[2] == var_0005[2] then
                        var_0012 = unknown_0016H(644, var_0010)
                        var_0012 = var_0012 * var_000C
                        while var_0012 > 100 do
                            var_0013 = unknown_0024H(644)
                            if var_0013 then
                                var_000D = unknown_0017H(var_0012, var_0013)
                                var_000D = unknown_0026H(var_0011)
                            end
                            var_0012 = var_0012 - 100
                        end
                        var_0013 = unknown_0024H(644)
                        if var_0013 then
                            var_000D = unknown_0017H(var_0012, var_0013)
                            var_000D = unknown_0026H(var_0011)
                        end
                        unknown_0089H(11, var_0010)
                        var_0014 = math.abs(var_0005[2] - var_0011[2]) - 4
                        var_0015 = "@A winnah in lane " .. var_0014 .. "!@"
                        unknown_0933H(1, var_0015, 232)
                    end
                    unknown_006FH(var_0010)
                end
            end
        elseif not get_flag(35) then
            set_flag(35, true)
        elseif not get_flag(36) then
            set_flag(36, true)
        elseif not get_flag(37) and get_flag(36) then
            set_flag(34, false)
            set_flag(35, false)
            set_flag(36, false)
            set_flag(37, false)
            var_0000 = unknown_0030H(764)
            for var_0003 in ipairs(var_0000) do
                get_object_frame(var_0003, 0)
            end
        end
    end
end