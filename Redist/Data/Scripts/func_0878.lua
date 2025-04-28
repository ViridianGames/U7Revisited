require "U7LuaFuncs"
-- Function 0878: De Snel combat training
function func_0878(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local2 = select_training_target(eventid, itemref)
    if local2 == 0 then
        return
    end
    local3 = 2
    local4 = check_training_eligibility(local3, local2, eventid, itemref)
    if local4 == 0 then
        say(itemref, "\"Thou dost not have enough practical experience to study fighting with me at this time!\" he scoffs.")
        return
    elseif local4 == 1 then
        local5 = check_gold(-359, -359, 644, -357)
        say(itemref, "\"You gather your gold and count it, finding that you have " .. local5 .. " gold altogether.\"")
        if local5 < eventid then
            say(itemref, "\"Hmmm... it appears thou art without the necessary amount of gold. When thy coffers are more full, I might be able to help thee.\" He smirks.")
            return
        end
    elseif local4 == 2 then
        say(itemref, "\"Thou art already close in skill to me! Thou hast peaked in thine own potential. There is nothing further I can do for thee.\"")
        return
    end
    local6 = remove_gold(true, -359, -359, 644, eventid)
    say(itemref, "\"You pay " .. eventid .. " gold, and the training session begins.\"")
    local7 = _GetNPCName(local2)
    local8 = _GetPlayerName(local2)
    if local7 == local8 then
        local7 = "you"
    end
    say(itemref, "\"The session, which consists of various techniques involving sleight of hand and strike feints, takes a fairly short amount of time.~ De Snel straightens suddenly and sheathes his blade. \\\"That is all for now. If thou dost wish more training, thou couldst most assuredly benefit from mine experience.\\\" He looks " .. local7 .. " up and down insolently. \\\"Thou seemest to be an apt pupil. Thou mayest return at a later time and advance thy training.\\\"")
    local9 = get_stat(4, local2)
    if local9 < 30 then
        train_combat(2, local2)
    end
    return
end