-- Manages Trinsic guard interactions, handling confrontations, bribe negotiations, and imprisonment based on player actions and location.
function func_0625(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25

    if eventid ~= 1 then
        if eventid == 2 then
            local14 = get_party_members()
            for local15 in ipairs(local14) do
                local16 = local15
                local17 = local16
                set_schedule(local17, 31)
                set_object_frame(local17, 0)
            end
            local18 = {295, 420}
            external_003EH(-357, local18) -- Unmapped intrinsic
            local19 = add_item(-359, 10, 828)
            if local19 and local19 == 1 then
                local13 = external_081FH(local19) -- Unmapped intrinsic
            end
            external_084AH() -- Unmapped intrinsic
            local13 = add_item(-356, {1596, 8021, 1, 7719})
        end
        return
    end

    local0 = get_item_type(itemref)
    local1 = {273, 379}
    local2 = {307, 440}
    local3 = get_item_data(-356)
    if get_location() == 0 then -- Unmapped intrinsic
        switch_talk_to(259, 0)
        add_dialogue("You see an irate guard.~~Years of indoctrination have instilled in him an overly developed sense of discipline~~and a zealous devotion to the maintainance of order. All of this zeal is now directed against you.~~ \"Such behavior will never be tolerated inside the sanctuary of Trinsic's walls.~~Thy red cloak and blonde curls show only that thou art a vile imposter and not a true Avatar.~~To the Death!\"")
        hide_npc(259)
        external_007CH() -- Unmapped intrinsic
        return
    end

    if local2[local1[local3]] then
        switch_talk_to(258, 0)
        add_dialogue("The guard glares at you. \"Unrepentant scoundrel!\"")
        hide_npc(258)
        external_007CH() -- Unmapped intrinsic
        return
    end

    switch_talk_to(258, 0)
    local4 = count_items(-359, -359, 644, -357) -- Unmapped intrinsic
    if get_random(1, 2) == 1 and local4 then
        add_dialogue("You see an angry guard. \"Cease and desist immediately!.~~Dost thou wish to avoid the unpleasantries of a lengthy trial?\"")
        local5 = get_answer()
        if not local5 then
            add_dialogue("\"What is your liberty worth?\"")
            if external_084BH(local4) then -- Unmapped intrinsic
                add_dialogue("The guard looks unimpressed by your paltry offer. \"How about a bit more? Our jail is populated by some unsavory characters.\"")
                if not external_084BH(local4) then -- Unmapped intrinsic
                    if is_player_female() then
                        local6 = "woman"
                    else
                        local6 = "man"
                    end
                    local7 = {946, 806, 720, 394}
                    local8 = {}
                    for local9 in ipairs(local7) do
                        local10 = local9
                        local11 = add_item(local7[local10], 30, itemref)
                    end
                    for local12 in ipairs(local8) do
                        local13 = local12
                        set_schedule(local13, 12)
                    end
                    local15 = add_item(8, 30, -359, itemref)
                    add_dialogue("The guard winks. \"I am pleased to see that thou art a thinking " .. local6 .. ". I will take care of this disturbance.\"")
                    play_music(itemref, 255)
                    return
                end
            end
        end
    end

    add_dialogue("You see an angry guard. \"Cease and desist immediately!.~~Wilt thou come quietly?\"")
    local5 = get_answer()
    if not local5 then
        add_dialogue("\"Very well. Thou shalt remain in prison until we see fit to release thee.\"")
        hide_npc(258)
        add_item(-356, 2, 5, {17447, 8046, 1573, 7765})
        local13 = add_item(-356, {1596, 8021, 1, 7719})
        return
    end

    add_dialogue("\"An unfortunate decision, my friend.\"")
    external_007CH() -- Unmapped intrinsic
    return
end