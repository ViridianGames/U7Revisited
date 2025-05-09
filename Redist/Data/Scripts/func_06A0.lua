--- Best guess: Manages Erethian’s spell-casting sequence in a dungeon, creating a well and tools, relocating items to a chest, and adjusting the environment based on flags.
function func_06A0(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016

    var_0000 = unknown_0035H(16, 10, 275, itemref)
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = false
    for i = 1, 5 do
        var_0005 = unknown_0014H(var_0000)
        var_0006 = unknown_0012H(var_0000)
        var_0007 = unknown_0018H(var_0000)
        if var_0006 == 6 then
            if var_0005 == 3 then
                var_000B = unknown_000EH(1, 675, var_0000)
                var_000C = unknown_0012H(var_000B)
                if var_000B and var_000C == 16 then
                    var_0001 = var_000B
                    var_0002 = var_0007
                end
            end
            if var_0005 == 7 then
                var_000B = unknown_000EH(1, 999, var_0000)
                var_000C = unknown_0012H(var_000B)
                if var_000B and var_000C == 1 then
                    var_0003 = var_000B
                    var_0004 = var_0007
                end
            end
        end
    end
    if var_0001 and var_0003 then
        switch_talk_to(1, 286)
        add_dialogue("Amidst muttered curses detailing the uselessness of ether and bothersome inter-dimensional beings, Erethian intones the magical words,")
        add_dialogue("\"An Vas Ailem!   Kal Bet Ailem!\"")
        hide_npc(286)
        var_000D = unknown_0001H(1697, {8021, 3, 17447, 8033, 3, 17447, 8048, 4, 17447, 7791}, itemref)
        unknown_006FH(var_0001)
        unknown_006FH(var_0003)
        unknown_0053H(1, 0, 0, 0, var_0002[2] - 2, var_0002[1] - 2, 5)
        unknown_0053H(1, 0, 0, 0, var_0004[2] - 2, var_0004[1] - 1, 4)
        unknown_000FH(8)
    else
        var_000E = false
        var_0000 = unknown_0035H(16, 10, 275, itemref)
        for i = 1, 5 do
            var_000F = unknown_0014H(var_0000)
            var_0010 = unknown_0012H(var_0000)
            var_0011 = unknown_0018H(var_0000)
            if var_0010 == 6 and var_000F == 10 then
                var_0012 = unknown_0035H(0, 1, 800, var_0000)
                if var_0012 then
                    for j = 1, 5 do
                        var_0014 = unknown_0018H(var_0012)
                        if var_0014 == var_0011 then
                            var_000E = var_0014
                            break
                        end
                    end
                end
            end
        end
        switch_talk_to(1, 286)
        add_dialogue("Little beads of sweat appear on the elderly mage's furrowed brow. \"That was a bit harder than I'd expected.\" He pauses to mop his forehead with the tip of his sleeve, \"I had to redirect a small underground river for the well to tap. Now, then. Thou shalt have need of some few tools to make use of this equipment, shan't thee?\" His rhetorical question goes unanswered as he once again prepares to unleash his will upon the world.")
        if var_000E and unknown_0014H(var_000E) == 100 then
            add_dialogue("He stops himself for a moment and says, \"If perchance thou hadst some item or other laying upon the floor here, thou'lt find it within yonder chest.\" He motions to the chest sitting on the floor, then continues with his spell.")
        end
        hide_npc(286)
        if not get_flag(3) then
            var_000D = unknown_0001H(1697, {8021, 2, 17447, 8033, 2, 17447, 8048, 2, 7719}, itemref)
        else
            var_000D = unknown_0001H(1698, {8021, 4, 17447, 8048, 3, 17447, 8033, 2, 17447, 8044, 3, 17447, 8045, 2, 17447, 8044, 2, 7719}, itemref)
        end
    end
    return
end