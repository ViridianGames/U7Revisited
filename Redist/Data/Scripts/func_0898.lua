-- Function 0898: Weapon shop dialogue
function func_0898(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"2-handed sword", "2-handed axe", "throwing axe", "sword", "mace", "spear", "dagger", "sling", "nothing"}
    local2 = {602, 601, 593, 599, 659, 592, 594, 474, 0}
    local3 = {-359}
    local4 = {250, 100, 25, 100, 20, 25, 20, 20, 0}
    local5 = {"a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", ""}
    local6 = {1, 1, 0, 0, 0, 0, 0, 0, 0}
    local7 = {"", "", "", "", "", "", "", "", ""}
    local8 = 1
    add_dialogue(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue(itemref, "\"Fine.\"")
            local0 = false
        end
        local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
        local11 = 0
        add_dialogue(itemref, "^" .. local10 .. " A fair price, yes?")
        local12 = get_answer()
        if local12 then
            if local2[local9] == 722 or local2[local9] == 723 then
                add_dialogue(itemref, "\"How many dozen wouldst thou like?\"")
                local11 = call_08F8H(true, 1, 5, local4[local9], local8, local3[0], local2[local9])
            else
                local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[0], local2[local9])
            end
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
    _RestoreAnswers()
    return
end