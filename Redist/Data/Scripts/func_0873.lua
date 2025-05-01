-- Function 0873: Armor shop dialogue
function func_0873(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"leather armour", "chain leggings", "leather leggings", "wooden shield", "leather helm", "nothing"}
    local2 = {569, 575, 574, 572, 1004, 0}
    local3 = {-359}
    local4 = {40, 70, 25, 15, 25, 0}
    local5 = {"", "", "", "a ", "a ", ""}
    local6 = {0, 1, 1, 0, 0, 0}
    local7 = {"", " for a pair", " for a pair", "", "", ""}
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
        add_dialogue(itemref, "^" .. local10 .. " Is that acceptable?")
        local12 = get_answer()
        if local12 then
            local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[0], local2[local9])
        end
        if local11 == 1 then
            add_dialogue(itemref, "\"Very good. At last we are getting somewhere!\"")
        elseif local11 == 2 then
            add_dialogue(itemref, "\"Thou hast thine hands full, idiot!\"")
        elseif local11 == 3 then
            add_dialogue(itemref, "\"Thou hast a lot of gall attempting to buy something from my shop without enough gold in thy possession!\"")
        end
        add_dialogue(itemref, "\"Anything else for thee today?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    _RestoreAnswers()
    return
end