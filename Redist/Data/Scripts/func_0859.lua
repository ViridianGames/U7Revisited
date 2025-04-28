require "U7LuaFuncs"
-- Function 0859: Armor shop dialogue
function func_0859(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"gauntlets", "scale armour", "gorget", "plate leggings", "plate armour", "great helm", "nothing"}
    local2 = {580, 570, 586, 576, 573, 541, 0}
    local3 = {-359}
    local4 = {25, 100, 40, 200, 325, 200, 0}
    local5 = {"", "", "a ", "", "", "a ", ""}
    local6 = {1, 0, 0, 1, 0, 0, 0}
    local7 = {" for a pair", "", "", " for a pair", "", "", ""}
    local8 = 1
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Tsk tsk... I am broken-hearted...\"")
            local0 = false
        else
            local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
            local11 = 0
            say(itemref, "^" .. local10 .. " Is that acceptable?\"")
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
    end
    _RestoreAnswers()
    return
end