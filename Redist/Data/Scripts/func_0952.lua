-- Function 0952: Weapon shop
function func_0952(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"2-handed axe", "2-handed sword", "sword", "mace", "dagger", "throwing axe", "nothing"}
    local2 = {601, 602, 599, 659, 594, 593, 0}
    local3 = {70, 125, 70, 15, 12, 20, 0}
    add_dialogue(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local4 = call_090CH(local1)
        if local4 == 1 then
            add_dialogue(itemref, "\"Fine.\"")
            local0 = false
        end
        local5 = "a "
        local6 = -359
        local7 = 0
        local8 = ""
        local9 = 1
        local10 = call_091BH(local8, local3[local4], local7, local1[local4], local5)
        local11 = 0
        add_dialogue(itemref, "^" .. local10 .. " Wilt thou buy it at that price?")
        local12 = get_answer()
        if local12 then
            local13 = call_08F8H(true, 1, 0, local3[local4], local9, local6, local2[local4])
            local11 = local13
        end
        if local11 == 1 then
            add_dialogue(itemref, "\"Done!\"")
        elseif local11 == 2 then
            add_dialogue(itemref, "\"Thou cannot possibly carry that much!\"")
        elseif local11 == 3 then
            add_dialogue(itemref, "\"Thou dost not have enough gold for that!\"")
        end
        add_dialogue(itemref, "\"Wouldst thou like something else?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    return
end