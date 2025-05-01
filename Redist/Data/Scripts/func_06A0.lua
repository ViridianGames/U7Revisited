-- Function 06A0: Erethian's spellcasting and tool spawning
function func_06A0(eventid, itemref)
    -- Local variables (23 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10
    local local11, local12, local13, local14, local15, local16, local17, local18, local19, local20
    local local21, local22

    local1 = false
    local2 = false
    local3 = false
    local4 = false

    -- Check for bucket (frame 6, quality 3) and hammer (frame 6, quality 7)
    local0 = callis_0035(16, 10, 275, itemref)
    while sloop() do
        local7 = local0
        local8 = call_GetItemQuality(local7)
        local9 = call_GetItemFrame(local7)
        local10 = callis_0018(local7)
        if local9 == 6 then
            if local8 == 3 then
                local11 = callis_000E(1, 675, local7)
                local12 = call_GetItemFrame(local11)
                if local11 and local12 == 16 then
                    local1 = local11
                    local2 = local10
                end
            elseif local8 == 7 then
                local11 = callis_000E(1, 999, local7)
                local12 = call_GetItemFrame(local11)
                if local11 and local12 == 1 then
                    local3 = local11
                    local4 = local10
                end
            end
        end
    end

    if local1 and local3 then
        switch_talk_to(286, 1)
        add_dialogue("Amidst muttered curses detailing the uselessness of ether and bothersome inter-dimensional beings, Erethian intones the magical words,")
        add_dialogue("\"An Vas Ailem!   Kal Bet Ailem!\"*")
        _HideNPC(-286)

        -- Spawn well and tools
        local array = {
            1697, 8021, 3, 17447,
            8033, 3, 17447,
            8048, 4, 17447,
            7791
        }
        local13 = callis_0001(array, itemref)
        callis_006F(local1)
        callis_006F(local3)
        callis_0053(-1, 0, 0, 0, local2[2] - 2, local2[1] - 1, 5)
        callis_0053(-1, 0, 0, 0, local4[2] - 2, local4[1] - 1, 4)
        call_000FH(8)
    else
        local14 = false
        local0 = callis_0035(16, 10, 275, itemref)
        while sloop() do
            local7 = local0
            local8 = call_GetItemQuality(local7)
            local9 = call_GetItemFrame(local7)
            local10 = callis_0018(local7)
            if local9 == 6 and local8 == 10 then
                local17 = callis_0035(0, 1, 800, local7)
                if local17 then
                    while sloop() do
                        local20 = local17
                        local21 = callis_0018(local20)
                        if local21 == local10 then
                            local14 = local20
                        end
                    end
                end
            end
        end

        switch_talk_to(286, 1)
        add_dialogue("Little beads of sweat appear on the elderly mage's furrowed brow. \"That was a bit harder than I'd expected.\" He pauses to mop his forehead with the tip of his sleeve, \"I had to redirect a small underground river for the well to tap. Now, then. Thou shalt have need of some few tools to make use of this equipment, shan't thee?\" His rhetorical question goes unanswered as he once again prepares to unleash his will upon the world.")
        if local14 and call_GetItemQuality(local14) == 100 then
            add_dialogue("He stops himself for a moment and says, \"If perchance thou hadst some item or other laying upon the floor here, thou'lt find it within yonder chest.\" He motions to the chest sitting on the floor, then continues with his spell.*")
        end
        _HideNPC(-286)

        if not get_flag(0x0003) then
            local array = {
                1697, 8021, 2, 17447,
                8033, 2, 17447,
                8048, 2, 7719
            }
            local13 = callis_0001(array, itemref)
        else
            local array = {
                1698, 8021, 4, 17447,
                8048, 3, 17447,
                8033, 2, 17447,
                8044, 3, 17447,
                8045, 2, 17447,
                8044, 2, 7719
            }
            local13 = callis_0001(array, itemref)
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function sloop()
    return false -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end