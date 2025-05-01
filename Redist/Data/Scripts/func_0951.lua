-- Function 0951: Tavern shop
function func_0951(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    call_0909H()
    local0 = true
    local1 = {"ale", "wine", "cake", "Silverleaf", "trout", "mead", "bread", "mutton", "nothing"}
    local2 = {616, 616, 377, 377, 377, 616, 377, 377, 0}
    local3 = {3, 5, 5, 31, 12, 0, 1, 8, -359}
    local4 = {2, 3, 2, 30, 3, 7, 2, 3, 0}
    local5 = {" for one bottle", " for one bottle", " for one slice", " for one portion", " for one portion", " for one bottle", " for one loaf", " for one portion", ""}
    local6 = ""
    local7 = 0
    local8 = 1
    add_dialogue(itemref, "\"What wouldst thou like?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue(itemref, "\"Fine.\"")
            local0 = false
        elseif local9 == 6 then
            if not get_flag(299) then
                add_dialogue(itemref, "\"I regret to tell thee that this fine establishment will no longer be able to provide our fine customers with Silverleaf. The person who provides me with the delicate meal is no longer able to procure it. I am dreadfully sorry, " .. (get_player_name() or "Avatar") .. ".\"")
                return
            end
        end
        local10 = local5[local9]
        local11 = local4[local9]
        local12 = local7
        local13 = local1[local9]
        local14 = local6
        local15 = call_091BH(local10, local11, local12, local13, local14)
        local16 = 0
        add_dialogue(itemref, "^" .. local15 .. " That is a fair price, is it not?")
        local17 = get_answer()
        if local17 then
            if local2[local9] == 377 then
                add_dialogue(itemref, "\"How many wouldst thou like?\"")
                local18 = call_08F8H(true, 1, 20, local4[local9], local8, local3[local9], local2[local9])
                local16 = local18
            else
                local19 = call_08F8H(true, 1, 0, local4[local9], local8, local3[local9], local2[local9])
                local16 = local19
            end
        end
        if local16 == 1 then
            add_dialogue(itemref, "\"Done!\"")
        elseif local16 == 2 then
            add_dialogue(itemref, "\"Thou cannot possibly carry that much!\"")
        elseif local16 == 3 then
            add_dialogue(itemref, "\"Thou dost not have enough gold for that!\"")
        end
        add_dialogue(itemref, "\"Wouldst thou like something else?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    return
end