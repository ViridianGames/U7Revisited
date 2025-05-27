--- Best guess: Manages the entry to the forge, handling Erethian's dialogue, mirror interactions, and flag-based sequences when event ID 2 or 3 is triggered.
function func_06F8(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030, var_0031

    if eventid == 3 then
        var_0000 = unknown_0014H(objectref)
        if var_0000 == 0 then
            var_0001 = unknown_000EH(10, 848, objectref)
            var_0002 = unknown_0012H(var_0001)
            if not var_0002 == 9 then
                unknown_0013H(3, var_0001)
            end
        elseif var_0000 == 1 then
            var_0003 = unknown_0035H(0, 1, 726, objectref)
            if var_0003 then
                set_flag(831, true)
            else
                set_flag(831, false)
            end
            if get_flag(831) and get_flag(828) then
                -- Skip
            end
        elseif var_0000 == 2 then
            var_0003 = unknown_0035H(0, 1, 726, objectref)
            if var_0003 then
                set_flag(828, true)
            else
                set_flag(828, false)
            end
            if get_flag(828) and get_flag(831) then
                -- Skip
            end
        elseif var_0000 == 4 then
            if get_flag(828) and get_flag(831) then
                -- Skip
            end
        end
        var_0004 = unknown_000EH(10, 990, objectref)
        if var_0004 then
            var_0005 = unknown_0018H(var_0004)
            var_0006 = unknown_0035H(0, 1, 955, var_0004)
            var_0007 = false
            for i = 1, #var_0006 do
                var_0010 = var_0006[i]
                var_0011 = unknown_0012H(var_0010)
                var_0012 = unknown_0018H(var_0010)
                if var_0011 == 8 and var_0012[1] == var_0005[1] - 1 and var_0012[2] == var_0005[2] and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                elseif var_0011 == 9 and var_0012[1] == var_0005[1] and var_0012[2] == var_0005[2] - 1 and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                elseif var_0011 == 10 and var_0012[1] == var_0005[1] and var_0012[2] == var_0005[2] and var_0012[3] == 4 then
                    var_0007 = var_0007 + 1
                end
            end
            if var_0007 == 3 then
                var_000D = false
                var_000E = unknown_0035H(0, 40, 435, 356)
                for i = 1, #var_000E do
                    var_0011 = var_000E[i]
                    var_0012 = unknown_0018H(var_0011)
                    if (var_0012[1] == 2208 or var_0012[1] == 2221) and var_0012[2] == 1514 and var_0012[3] == 1 then
                        var_000D = var_000D + 1
                    end
                end
                if var_000D == 2 then
                    unknown_087DH()
                    var_0013 = unknown_0018H(get_npc_name(356))
                    if var_0013[2] > var_0005[2] then
                        if unknown_005AH() then
                            unknown_0013H(20, unknown_0881H())
                        else
                            unknown_0013H(18, unknown_0881H())
                        end
                    else
                        if unknown_005AH() then
                            unknown_0013H(21, unknown_0881H())
                        else
                            unknown_0013H(19, unknown_0881H())
                        end
                    end
                    var_0014 = unknown_0024H(955)
                    unknown_0013H(7, var_0014)
                    unknown_0013H(1, var_0004)
                    var_0015 = unknown_0026H({var_0005[1] - 1, var_0005[2] - 1, var_0005[3] + 2})
                    unknown_0053H(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 7)
                    unknown_000FH(68)
                    unknown_0001H({1784, 17493, 7937, 31, 8006, 24, -1, 17419, 8014, 5, 7750}, var_0004)
                end
            end
        end
    elseif eventid == 2 then
        if not get_flag(780) then
            if not get_flag(750) then
                unknown_08FFH("@'Tis sad that Erethian's lust for power has brought him to this evil pass.@")
                unknown_08FFH("@Perhaps, at last, he is at rest.@")
            end
            if not unknown_0037H(23) then
                unknown_08FFH("@I am sure that Lord British even now awaits news of Exodus' exile.@")
            end
            unknown_08FFH("@It is time to leave this barren island behind.@")
            return
        end
        var_0005 = unknown_0018H(objectref)
        var_0013 = unknown_0018H(get_npc_name(356))
        if get_flag(831) and get_flag(828) then
            if not get_flag(750) then
                var_0017 = false
                var_0018 = false
                var_0019 = unknown_0035H(8, 80, 154, objectref)
                for i = 1, #var_0019 do
                    var_001C = var_0019[i]
                    if not unknown_002AH(4, 240, 797, var_001C) and not (unknown_0019H(objectref, var_001C) < 8) then
                        unknown_0053H(-1, 0, 0, 0, unknown_0018H(var_001C)[2] - 1, unknown_0018H(var_001C)[1] - 1, 13)
                        unknown_08E6H(var_001C)
                    else
                        var_0017 = var_001C
                    end
                end
                if not var_0017 then
                    var_0017 = unknown_0024H(154)
                    unknown_0089H(18, var_0017)
                    var_001E = unknown_0018H(get_npc_name(356))
                    if var_001E[2] > var_0013[2] then
                        unknown_0013H(19, var_0017)
                        var_001D = {1510, 2}
                    else
                        unknown_0013H(3, var_0017)
                        var_001D = {1518, 2}
                    end
                    var_0015 = unknown_0026H(var_001D)
                    unknown_0053H(-1, 0, 0, 0, var_001D[2] - 1, var_001D[1] - 1, 13)
                    unknown_0001H({8048, 5, 8487, var_0013[2], 7769}, var_0017)
                end
                unknown_0059H(1)
                unknown_0053H(-1, 0, 0, 0, var_0013[1], var_0013[2], 17)
                unknown_000FH(62)
                set_flag(828, false)
                unknown_0002H(7, 1784, {7765}, objectref)
                return
            end
            switch_talk_to(286, 1)
            add_dialogue("\"No! Thou must not do this!\" Erethian's voice is full of anguish. He raises his arms and begins a powerful spell.")
            add_dialogue("\"Vas Ort Rel Tym...\"")
            add_dialogue("He stops mid-spell and begins another, pointing towards the Talisman of Infinity.")
            add_dialogue("\"Vas An Ort Ailem!\"")
            add_dialogue("You immediately recognize the resonance of a spell gone awry, and apparently so does Erethian. A look of horror comes to his wrinkled features which appear to become more lined by the second.*")
            var_001C = unknown_000EH(10, 154, objectref)
            unknown_0001H({8045, 2, 17447, 8044, 2, 7719}, var_001C)
            unknown_0059H(1)
            var_0022 = unknown_0035H(16, 10, 275, objectref)
            for i = 1, #var_0022 do
                var_0025 = var_0022[i]
                if unknown_0012H(var_0025) == 7 and unknown_0014H(var_0025) == 1 then
                    var_0026 = unknown_0018H(var_0025)
                    unknown_0053H(3, 0, 0, 0, var_0026[2], var_0026[1], 17)
                end
            end
            unknown_0053H(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 17)
            set_flag(828, false)
            set_flag(831, true)
            unknown_0002H(7, 1784, {7765}, objectref)
            return
        end
        if not get_flag(831) then
            if not get_flag(750) then
                var_001C = unknown_000EH(10, 528, objectref)
                var_0027 = unknown_0012H(var_001C)
                var_0028 = unknown_0018H(var_001C)
                unknown_08E6H(var_001C)
                var_0029 = unknown_0024H(892)
                unknown_0089H(18, var_0029)
                if var_0027 == 12 then
                    unknown_0013H(14, var_0029)
                elseif var_0027 == 28 then
                    unknown_0013H(22, var_0029)
                end
                var_0015 = unknown_0026H(var_0028)
                set_flag(750, true)
                unknown_002EH(0, 17)
            end
            unknown_0059H(1)
            var_0022 = unknown_0035H(16, 10, 275, objectref)
            for i = 1, #var_0022 do
                var_0025 = var_0022[i]
                if unknown_0012H(var_0025) == 7 and unknown_0014H(var_0025) == 2 then
                    var_0026 = unknown_0018H(var_0025)
                    unknown_0053H(3, 0, 0, 0, var_0026[2], var_0026[1], 17)
                end
            end
            unknown_0053H(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 17)
            unknown_0053H(-1, 0, 0, 0, var_0005[2] - 2, var_0005[1] - 2, 8)
            unknown_000FH(9)
            var_0006 = unknown_0035H(0, 1, 955, objectref)
            for i = 1, #var_0006 do
                var_0010 = var_0006[i]
                var_0011 = unknown_0012H(var_0010)
                if var_0011 == 7 then
                    unknown_006FH(var_0010)
                elseif var_0011 == 8 then
                    unknown_006FH(var_0010)
                elseif var_0011 == 9 then
                    unknown_006FH(var_0010)
                elseif var_0011 == 10 then
                    unknown_006FH(var_0010)
                end
            end
            unknown_008AH(16, 356)
            unknown_0002H(14, 17453, {7724}, unknown_0881H())
            unknown_0001H({1693, 8021, 12, 7719}, get_npc_name(356))
            var_0030 = unknown_000EH(10, 726, objectref)
            if var_0030 then
                unknown_0001H({1784, 8021, 16, 7719}, var_0030)
            end
            unknown_006FH(objectref)
            set_flag(780, true)
        end
    end
    return
end