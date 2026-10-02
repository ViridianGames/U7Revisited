--- Best guess: Manages a training session dialogue with Jillian, checking player stats and gold, and applying stat increases upon successful payment.
function utility_unknown_0930(var_0000, var_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    var_0002 = utility_unknown_1056()
    var_0003 = get_npc_name(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 2
    var_0005 = utility_unknown_1058(var_0004, var_0002, var_0000, var_0001)
    if var_0005 == 0 then
        add_dialogue("\"I am sorry, but it appears thou dost not have enough knowledge of elementary studies to train at this time. If thou couldst return at a future date, I could instruct thee then.\"")
        return
    elseif var_0005 == 1 then
        var_0006 = get_party_gold()
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < var_0000 then
            add_dialogue("\"I am sorry, but thou dost not seem to have enough gold to train now.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("After giving a few test questions, she exclaims, \"Thou art easily as well educated as I! There is nothing I have that could help thee.\"")
        return
    end
    var_0007 = remove_party_items(true, 359, 359, 644, var_0000)
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    if var_0002 == 356 then
        var_0008 = "You"
        var_0009 = "you"
        var_0010 = ""
    else
        var_0008 = var_0003
        var_0009 = var_0003
        var_0010 = "s"
    end
    add_dialogue(var_0008 .. " and Jillian study for some time. In addition, she teaches a little on the theory of magic. Afterwards, " .. var_0009 .. " notice" .. var_0010 .. " an increase in knowledge and magical understanding.")
    var_0011 = utility_unknown_1040(6, var_0002)
    if var_0011 < 30 then
        utility_unknown_1048(1, var_0002)
    end
    var_0012 = utility_unknown_1040(2, var_0002)
    if var_0012 < 30 then
        utility_unknown_1046(1, var_0002)
    end
    return
end