require "U7LuaFuncs"
-- Function 0897: Armor shop dialogue
function func_0897(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"leather gloves", "plate armour", "chain armour", "leather armour", "spiked shield", "crested helm", "nothing"}
    local2 = {579, 573, 571, 569, 578, 542, 0}
    local3 = {-359}
    local4 = {20, 300, 150, 50, 60, 75, 0}
    local5 = {"", "", "", "", "a ", "a ", ""}
    local6 = {1, 0, 0, 0, 0, 0, 0}
    local7 = {" for a pair", "", "", "", "", "", ""}
    local8 = 1
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Fine.\"")
            local0 = false
        end
        local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
        local11 = 0
        say(itemref, "^" .. local10 .. " A fair price, yes?")
        local12 = get_answer()
        if local12 then
            local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[0], local2[local9])
        end
        if local11 == 1 then
            say(itemref, "\"Done!\"")
        elseif local11 == 2 then
            say(itemref, "\"Thou cannot possibly carry that much!\"")
        elseif local11 == 3 then
            say(itemref, "\"Thou dost not have enough gold for that!\"")
        end
        say(itemref, "\"Wouldst thou like something else?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    _RestoreAnswers()
    return
end