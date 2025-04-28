require "U7LuaFuncs"
-- Function 0855: Tavern shop dialogue
function func_0855(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local0 = _GetPlayerName(eventid)
    _SaveAnswers()
    local1 = true
    local2 = {"wine", "ale", "fish", "mead", "jerky", "nothing"}
    local3 = {616, 616, 377, 616, 377, 0}
    local4 = {5, 3, 12, 0, 15, -359}
    local5 = {1, 2, 5, 5, 12, 0}
    local6 = {""}
    local7 = 0
    local8 = {" for a bottle", " for a bottle", " for one", " for a bottle", " for ten pieces", ""}
    local9 = {1, 1, 1, 1, 10, 0}
    say(itemref, "\"What dost thou want for thy refreshment?\"")
    while local1 do
        local10 = call_090CH(local2)
        if local10 == 1 then
            say(itemref, "\"Fine.\"")
            local1 = false
        else
            local11 = call_091BH(local8[local10], local5[local10], local9[local10], local2[local10], local6[local10] or "")
            local12 = 0
            say(itemref, "^" .. local11 .. " Art thou still interested?\"")
            local13 = get_answer()
            if local13 then
                if local3[local10] == 377 then
                    local11 = "How many "
                    if local9[local10] > 1 then
                        local11 = local11 .. "packets "
                    end
                    local11 = local11 .. "wouldst thou like?"
                    say(itemref, "^" .. local11 .. "\"")
                    local12 = call_08F8H(true, 1, 20, local5[local10], local9[local10], local4[local10], local3[local10])
                else
                    local12 = call_08F8H(true, 1, 0, local5[local10], local9[local10], local4[local10], local3[local10])
                end
            end
            if local12 == 1 then
                say(itemref, "\"It is thine!\"")
            elseif local12 == 2 then
                say(itemref, "\"Thou cannot possibly carry that much!\"")
            elseif local12 == 3 then
                say(itemref, "\"Thou dost not have enough gold, " .. local0 .. ".\"")
            end
            say(itemref, "\"Wouldst thou care for something else?\"")
            local1 = get_answer()
        end
    end
    _RestoreAnswers()
    return
end