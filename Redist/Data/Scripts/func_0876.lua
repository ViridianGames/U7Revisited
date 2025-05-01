-- Function 0876: Tavern shop dialogue
function func_0876(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local0 = _GetPlayerName(eventid)
    _SaveAnswers()
    local1 = true
    local2 = {"milk", "ale", "wine", "mead", "cheese", "grapes", "cake", "ham", "trout", "bread", "mutton rations", "nothing"}
    local3 = {616, 616, 616, 616, 377, 377, 377, 377, 377, 377, 377, 0}
    local4 = {7, 3, 5, 0, 26, 19, 5, 11, 12, 0, 15, -359}
    local5 = {4, 2, 5, 10, 3, 3, 1, 15, 3, 6, 16, 0}
    local6 = {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0}
    local7 = {" for a bottle", " for a bottle", " for a bottle", " for a bottle", " for a hunk", " for a bunch", " for one piece", " for one slice", " for one portion", " for one loaf", " for 10 pieces", ""}
    local8 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 0}
    add_dialogue(itemref, "\"What wouldst thou choose to buy, " .. local0 .. "?\"")
    while local1 do
        local9 = call_090CH(local2)
        if local9 == 1 then
            add_dialogue(itemref, "\"Very well, " .. local0 .. ".\"")
            local1 = false
        end
        local10 = ""
        local11 = 0
        local12 = call_091BH(local7[local9], local5[local9], local6[local9], local2[local9], local10)
        add_dialogue(itemref, "^" .. local12 .. ". Dost thou find the price acceptable?")
        local13 = get_answer()
        if local13 then
            if local3[local9] == 616 then
                local11 = call_08F8H(true, 1, 0, local5[local9], local8[local9], local4[local9], local3[local9])
            else
                add_dialogue(itemref, "\"How many dost thou want to purchase?\"")
                local11 = call_08F8H(true, 1, 20, local5[local9], local8[local9], local4[local9], local3[local9])
            end
        end
        if local11 == 1 then
            add_dialogue(itemref, "\"Very good, " .. local0 .. ".\"")
        elseif local11 == 2 then
            add_dialogue(itemref, "\"I believe thou cannot carry that much, " .. local0 .. ".\"")
        elseif local11 == 3 then
            add_dialogue(itemref, "\"It would appear thou dost not have enough gold for that!\"")
        end
        add_dialogue(itemref, "\"Wouldst thou care to buy something else?\"")
        local1 = get_answer()
    end
    _RestoreAnswers()
    return
end