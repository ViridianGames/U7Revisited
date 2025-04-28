require "U7LuaFuncs"
-- Function 0946: Pastry shop
function func_0946(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"pastry", "rolls", "cake", "bread", "nothing"}
    local2 = {377, 377, 377, 377, 0}
    local3 = {6, 2, 5, 1, -359}
    local4 = {3, 4, 3, 4, 0}
    local5 = ""
    local6 = {0, 1, 0, 0, 0}
    local7 = {" for one", " for a batch", " for a slice", " for a loaf", ""}
    local8 = 1
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Fine.\"")
            local0 = false
        end
        local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5)
        local11 = 0
        say(itemref, "^" .. local10 .. " A fair price, wouldst thou not agree?")
        local12 = get_answer()
        if local12 then
            say(itemref, "\"How many wouldst thou like?\"")
            local11 = call_08F8H(true, 1, 20, local4[local9], local8, local3[local9], local2[local9])
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