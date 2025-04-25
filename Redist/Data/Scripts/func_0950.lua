-- Function 0950: Boxing training
function func_0950(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16

    local2 = call_0920H(eventid, itemref)
    local3 = get_player_name() or "Avatar"
    local4 = is_player_female()
    if local2 == -356 then
        local3 = "you"
        local5 = "You"
        local6 = "mimic"
        local7 = "develop"
        local8 = "you"
        local9 = "you"
        local10 = "feel"
        local11 = "have"
        local12 = "learn"
    else
        if local4 then
            local5 = "She"
            local9 = "she"
        else
            local5 = "He"
            local9 = "he"
        end
        local6 = "mimics"
        local7 = "develops"
        local8 = "them"
        local10 = "feels"
        local11 = "has"
        local12 = "learns"
    end
    if local2 == 0 then
        say(itemref, "\"It appears that thou dost not have enough practical experience to train at this time. If thou couldst return later after thou hast gained more experience, I can help thee.\"")
        return
    end
    local13 = 2
    local14 = call_0922H(local13, local2, local0, local1)
    if local14 == 0 then
        say(itemref, "\"It appears that thou dost not seem to have enough gold to train here. If thou couldst return later after thy pockets are filled...\"")
        return
    elseif local14 == 1 then
        local15 = check_condition(-359, -359, 644, -357)
        say(itemref, "You gather your gold and count it, finding that you have " .. local15 .. " gold altogether.")
        if local15 < local0 then
            say(itemref, "\"It appears that thou dost not seem to have enough gold to train here. If thou couldst return later after thy pockets are filled...\"")
            return
        end
    elseif local14 == 2 then
        say(itemref, "\"It appears that thou art already as proficient as I! I am afraid that thou cannot be trained further here.\"")
        return
    end
    say(itemref, "You pay " .. local0 .. " gold.")
    local16 = remove_item(true, -359, -359, 644, local0)
    say(itemref, "Zella begins the session by showing " .. local3 .. " the proper stance when 'boxing'.~~\"'Tis all contingent on balance. Use thy weight to control thy movement. Step lightly. 'Tis almost like a dance.\" Zella shows " .. local3 .. " some steps, sparring into the air. " .. local5 .. " " .. local6 .. " him and slowly " .. local7 .. " a feel for the technique. After a while it becomes second nature. The two of " .. local8 .. " take jabs at each other, and " .. local3 .. " " .. local12 .. " proper defensive maneuvers. When the session is over, " .. local5 .. " " .. local10 .. " " .. local9 .. " " .. local11 .. " a better grip on the concept of 'boxing'.")
    local17 = call_0910H(1, local2)
    local18 = call_0910H(4, local2)
    if local17 < 30 then
        call_0915H(1, local2)
    end
    if local18 < 30 then
        call_0917H(1, local2)
    end
    return
end