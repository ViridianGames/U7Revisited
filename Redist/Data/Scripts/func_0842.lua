-- Function 0842: Tavern shop dialogue
function func_0842(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    _SaveAnswers()
    local0 = _GetPlayerName(eventid)
    local1 = _IsPlayerFemale()
    local2 = true
    local3 = {"ale", "wine", "cake", "Silverleaf", "flounder", "mead", "bread", "mutton", "nothing"}
    local4 = {616, 616, 377, 377, 377, 616, 377, 377, 0}
    local5 = {3, 5, 4, 31, 13, 0, 0, 8, -359}
    local6 = {2, 3, 2, 30, 3, 7, 2, 3, 0}
    local7 = {""}
    local8 = 0
    local9 = {" per bottle", " per bottle", " for one portion", " for one portion", " for one portion", " for one bottle", " for one loaf", " for one portion", ""}
    local10 = {1, 1, 1, 1, 1, 1, 1, 1, 0}
    add_dialogue(itemref, "\"What wouldst thou like?\"")
    while local2 do
        local11 = call_090CH(local3)
        if local11 == 1 then
            add_dialogue(itemref, "\"Nothing at all? Well, alright.\"")
            if not local1 then
                add_dialogue(itemref, "She bats her eyelashes at you and grins.")
            end
            local2 = false
        elseif local11 == 6 and not get_flag(299) then
            add_dialogue(itemref, "\"I have none to sell thee, " .. local0 .. ", for the logger will no longer supply it.\"")
        else
            local12 = call_091BH(local9[local11], local6[local11], local10[local11], local3[local11], local7[local11] or "")
            local13 = 0
            add_dialogue(itemref, "^" .. local12 .. " Is that price all right?\"")
            local14 = get_answer()
            if local14 then
                if local4[local11] == 377 then
                    add_dialogue(itemref, "\"How many wouldst thou like?\"")
                    local13 = call_08F8H(true, 1, 20, local6[local11], local10[local11], local5[local11], local4[local11])
                else
                    local13 = call_08F8H(true, 1, 0, local6[local11], local10[local11], local5[local11], local4[local11])
                end
            end
            if local13 == 1 then
                add_dialogue(itemref, "\"'Tis thine!\"")
            elseif local13 == 2 then
                add_dialogue(itemref, "\"Thou cannot possibly carry that much, " .. local0 .. "!\"")
            elseif local13 == 3 then
                add_dialogue(itemref, "\"Hmmm. Thou dost not have enough gold!\"")
            end
            add_dialogue(itemref, "\"Wouldst thou like something else?\"")
            local2 = get_answer()
        end
    end
    _RestoreAnswers()
    return
end