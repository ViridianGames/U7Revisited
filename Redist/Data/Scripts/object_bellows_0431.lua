--- Best guess: Controls a bellows in a forge, animating it and heating a sword blank (ID 668) over a firepit (ID 739), adjusting frames based on position and state for a crafting sequence.
function object_bellows_0431(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006
    local var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D
    local var_000E, var_000F

    var_0000 = get_object_frame(objectref)
    if var_0000 >= 3 and var_0000 <= 5 then
        if eventid == 1 then
            -- call [0000] (0828H, unmapped)
            utility_position_0808(7, objectref, 431, -1, 0, 1, objectref)
        elseif eventid == 7 then
            var_0001 = execute_usecode_array({{3, 8006, 1, 7975}, {4, 8006, 1, 7975}, {5, 8006, 1, 7975}, {4, 17478, 7937, 47, 7768}}, objectref)
            -- call [0001] (092DH, unmapped)
            var_0002 = utility_unknown_1069(objectref)
            var_0001 = execute_usecode_array({8033, 3, 17447, 8556, var_0002, 7769}, 356)
            var_0003 = find_nearest(3, 739, objectref)
            var_0004 = get_object_frame(var_0003)
            var_0005 = find_nearest(3, 668, objectref)
            var_0006 = get_object_frame(var_0005)
            if not var_0003 then
                if var_0004 == 4 then
                    var_0001 = execute_usecode_array({{4, 8006, 15, 7975}, {5, 8006, 1, 7719}}, var_0003)
                elseif var_0004 == 5 then
                    var_0001 = execute_usecode_array({{4, 8006, 15, 7975}, {5, 8006, 15, 7975}, {6, 8006, 1, 7719}}, var_0003)
                elseif var_0004 == 6 then
                    var_0001 = execute_usecode_array({{4, 8006, 15, 7975}, {5, 8006, 15, 7975}, {6, 8006, 15, 7975}, {7, 8006, 1, 7719}}, var_0003)
                elseif var_0004 == 7 then
                    var_0001 = execute_usecode_array({{4, 8006, 15, 7975}, {5, 8006, 15, 7975}, {6, 8006, 15, 7975}, {7, 8006, 1, 7719}}, var_0003)
                    if not var_0005 then
                        var_0007 = get_object_position(var_0003)
                        var_0008 = get_object_position(var_0005)
                        var_0009 = false
                        if aidx(var_0008, 1) == aidx(var_0007, 1) and aidx(var_0008, 2) + 1 == aidx(var_0007, 2) and aidx(var_0008, 3) - 2 == aidx(var_0007, 3) then
                            var_0009 = true
                        end
                        if var_0009 then
                            if var_0006 <= 7 then
                                return
                            elseif var_0006 >= 13 and var_0006 <= 15 then
                                var_0001 = execute_usecode_array({{1679, 8021, 25, 7975}, {8, 8006, 2, 7719}}, var_0005)
                            elseif var_0006 == 8 then
                                var_0001 = execute_usecode_array({{1679, 8021, 25, 7975}, {8, 8006, 25, 7975}, {9, 8006, 2, 7719}}, var_0005)
                            elseif var_0006 == 9 then
                                var_0001 = execute_usecode_array({{1679, 8021, 25, 7975}, {8, 8006, 25, 7975}, {9, 8006, 25, 7975}, {10, 8006, 2, 7719}}, var_0005)
                            elseif var_0006 == 10 then
                                var_0001 = execute_usecode_array({{1679, 8021, 25, 7975}, {8, 8006, 25, 7975}, {9, 8006, 25, 7975}, {10, 8006, 25, 7975}, {11, 8006, 2, 7719}}, var_0005)
                            elseif var_0006 == 11 or var_0006 == 12 then
                                var_0001 = execute_usecode_array({{1679, 8021, 25, 7975}, {8, 8006, 25, 7975}, {9, 8006, 25, 7975}, {10, 8006, 25, 7975}, {11, 8006, 25, 7975}, {12, 8006, 2, 7719}}, var_0005)
                            end
                        end
                    end
                end
            end
        end
    else
        if eventid == 1 then
            -- calli 005C, 1 (unmapped)
            halt_scheduled(objectref)
            -- call [0000] (0828H, unmapped)
            utility_position_0808(7, objectref, 431, -1, 0, 1, objectref)
        elseif eventid == 7 then
            -- calli 005C, 1 (unmapped)
            halt_scheduled(356)
            var_000A = execute_usecode_array({{0, 8006, 1, 7975}, {1, 8006, 1, 7975}, {2, 8006, 1, 7975}, {1, 8006, 1, 7975}, {0, 8006, 1, 7975}, {1, 8006, 1, 7975}, {2, 8006, 1, 7975}, {1, 8006, 1, 7937, 47, 7768}}, objectref)
            -- call [0002] (0827H, unmapped)
            var_0002 = utility_unknown_0807(objectref, 356)
            var_000A = execute_usecode_array({{8033, 3, 17447, 17516}, {8033, 3, 17447, 8545}, var_0002, 7769}, 356)
            var_000B = check_flag_location(176, 4, 739, objectref)
            while true do
                var_000C = var_000B
                var_000D = var_000C
                var_000E = var_000D
                var_000F = get_object_frame(var_000E)
                if var_000F == 0 then
                    var_000A = execute_usecode_array({{3, 8006, 2, 8006, 1, 8006, 0, 8006, 47, 17496, 7715}}, var_000E)
                    var_000A = delayed_execute_usecode_array({{18, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724}}, var_000E)
                elseif var_000F == 1 then
                    var_000A = execute_usecode_array({{3, 8006, 2, 8006, 1, 8006, 47, 17496, 7715}}, var_000E)
                    var_000A = delayed_execute_usecode_array({{17, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724}}, var_000E)
                elseif var_000F == 2 then
                    var_000A = execute_usecode_array({{3, 8006, 2, 8006, 47, 17496, 7715}}, var_000E)
                    var_000A = delayed_execute_usecode_array({{16, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724}}, var_000E)
                elseif var_000F == 3 then
                    var_000A = execute_usecode_array({{3, 8006, 47, 17496, 7715}}, var_000E)
                    var_000A = delayed_execute_usecode_array({{15, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724}}, var_000E)
                end
            end
        end
    end
    return
end