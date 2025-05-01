-- Function 0856: Bradman training dialogue
function func_0856(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local2 = select_training_target(eventid, itemref)
    local3 = _GetPlayerName(local2)
    if local2 == -356 then
        local3 = "you"
    end
    if local2 == 0 then
        return
    end
    if local2 == -1 or local2 == -10 then
        local0 = eventid / 2
        add_dialogue(itemref, "\"I cannot charge a master such as thyself full price.\"")
    end
    local4 = 2
    local5 = check_training_eligibility(local4, local2, eventid, itemref)
    if local5 == 0 then
        add_dialogue(itemref, "\"After a bit of target practice, he says, \\\"I am sorry to say this, but thou dost need more practice before I will be able to train thee. Perhaps at a later time thou wilt be in a better position to receive mine instruction.\\\"")
        return
    elseif local5 == 1 then
        local6 = check_gold(-359, -359, 644, -357)
        add_dialogue(itemref, "\"You gather your gold and count it, finding that you have " .. local6 .. " gold altogether.\"")
        if local6 < eventid then
            add_dialogue(itemref, "\"Thou hast not the gold to train.\"")
            return
        end
    elseif local5 == 2 then
        add_dialogue(itemref, "\"After a few target shots, he exclaims, \\\"Thou art already as proficient as I! I can do nothing to improve thy coordination of hand and eye!\\\"")
        return
    end
    local7 = remove_gold(true, -359, -359, 644, eventid)
    add_dialogue(itemref, "\"You pay " .. eventid .. " gold, and the training session begins.\"")
    if local2 == -356 then
        local8 = "You"
    else
        local8 = local3
    end
    if local2 == -356 then
        local9 = "you"
    else
        local9 = local3
    end
    local10 = local2 == -356 and "" or "s"
    add_dialogue(itemref, local8 .. " and Bradman spend some time taking target practice with the bow. Shortly, " .. local9 .. " notice" .. local10 .. " a significant increase in hand-eye coordination.")
    local11 = get_stat(1, local2)
    if local11 < 30 then
        train_strength(2, local2)
    end
    return
end