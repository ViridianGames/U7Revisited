require "U7LuaFuncs"
-- Function 0863: Weapon shop dialogue
function func_0863(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"bolts", "arrows", "triple crossbow", "crossbow", "bow", "nothing"}
    local2 = {723, 722, 647, 598, 597, 0}
    local3 = {-359}
    local4 = {30, 25, 400, 125, 40, 0}
    local5 = {"", "", "a ", "a ", "a ", ""}
    local6 = {1, 1, 0, 0, 0, 0}
    local7 = {" for a dozen", " for a dozen", "", "", "", ""}
    local8 = {12, 12, 1, 1, 1, 0}
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Fine.\"")
            local0 = false
        else
            local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
            local11 = 0
            say(itemref, "^" .. local10 .. " Wouldst thou still like to buy?\"")
            local12 = get_answer()
            if local12 then
                if local2[local9] == 722 or local2[local9] == 723 then
                    say(itemref, "\"How many dozen wouldst thou like?\"")
                    local11 = call_08F8H(true, 1, 20, local4[local9], local8[local9], local3[0], local2[local9])
                else
                    local11 = call_08F8H(false, 1, 0, local4[local9], local8[local9], local3[0], local2[local9])
                end
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