--- Best guess: Manages a training session dialogue with Jillian, checking player stats and gold, and applying stat increases upon successful payment.
function func_08A2(var_0000, var_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    var_0002 = unknown_0920H()
    var_0003 = unknown_0027H(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 2
    var_0005 = unknown_0922H(var_0004, var_0002, var_0000, var_0001)
    if var_0005 == 0 then
        add_dialogue("\"I am sorry, but it appears thou dost not have enough knowledge of elementary studies to train at this time. If thou couldst return at a future date, I could instruct thee then.\"")
        return
    elseif var_0005 == 1 then
        var_0006 = unknown_0028H(359, 359, 644, 357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < var_0000 then
            add_dialogue("\"I am sorry, but thou dost not seem to have enough gold to train now.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("After giving a few test questions, she exclaims, \"Thou art easily as well educated as I! There is nothing I have that could help thee.\"")
        return
    end
    var_0007 = unknown_002BH(true, 359, 359, 644, var_0000)
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
    var_0011 = unknown_0910H(6, var_0002)
    if var_0011 < 30 then
        unknown_0918H(1, var_0002)
    end
    var_0012 = unknown_0910H(2, var_0002)
    if var_0012 < 30 then
        unknown_0916H(1, var_0002)
    end
    return
end