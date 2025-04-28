require "U7LuaFuncs"
-- Function 0874: General store dialogue
function func_0874(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    _SaveAnswers()
    local0 = true
    local1 = {"bedroll", "swamp boots", "bucket", "lockpicks", "backpack", "torch", "nothing"}
    local2 = {583, 588, 810, 627, 801, 595, 0}
    local3 = {-359}
    local4 = {15, 40, 2, 8, 12, 4, 0}
    local5 = {"a ", "a pair of ", "a ", "some ", "a ", "a ", "a "}
    local6 = {0, 1, 0, 1, 0, 0, 0}
    local7 = {""}
    local8 = 1
    say(itemref, "\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"Fine.\"")
            local0 = false
        end
        local10 = call_091BH(local7[local9] or "", local4[local9], local6[local9], local1[local9], local5[local9])
        local11 = 0
        say(itemref, "^" .. local10 .. " Is that acceptable?")
        if local2[local9] == 627 or local2[local9] == 595 then
            local12 = get_answer()
            if local12 then
                say(itemref, "\"How many wouldst thou like?\"")
                local11 = call_08F8H(true, 1, 5, local4[local9], local8, local3[0], local2[local9])
            end
        else
            local13 = get_answer()
            if local13 then
                local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[0], local2[local9])
            end
        end
        if local11 == 1 then
            say(itemref, "\"Very good. At last we are getting somewhere!\"")
        elseif local11 == 2 then
            say(itemref, "\"Thou hast thine hands full, idiot!\"")
        elseif local11 == 3 then
            say(itemref, "\"Thou hast a lot of gall attempting to buy something from my shop without enough gold in thy possession!\"")
        end
        say(itemref, "\"Anything else for thee today?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    _RestoreAnswers()
    return
end