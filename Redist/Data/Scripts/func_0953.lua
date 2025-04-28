require "U7LuaFuncs"
-- Function 0953: Armor shop
function func_0953(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"crested helm", "plate leggings", "plate armour", "great helm", "gauntlets", "chain leggings", "chain armour", "chain coif", "nothing"}
    local2 = {542, 576, 573, 541, 580, 575, 571, 539, 0}
    local3 = {60, 120, 300, 150, 20, 50, 100, 80, 0}
    local4 = -359
    local5 = {"a ", "", "", "a ", "", "", "", "a ", ""}
    local6 = {0, 1, 0, 0, 1, 1, 0, 0, 0}
    local7 = {"", " for a pair", "", "", " for a pair", " for a pair", "", "", ""}
    local8 = 1
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Fine.\"")
            local0 = false
        end
        local10 = call_091BH(local7[local9], local3[local9], local6[local9], local1[local9], local5[local9])
        local11 = 0
        say(itemref, "^" .. local10 .. " Is that acceptable?")
        local12 = get_answer()
        if local12 then
            local13 = call_08F8H(false, 1, 0, local3[local9], local8, local4, local2[local9])
            local11 = local13
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
    return
end