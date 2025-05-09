--- Best guess: Manages a strength training session with Penni, teaching physical exercises, potentially increasing strength and combat ability, with gold and experience checks.
function func_08C8(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    var_0002 = unknown_0920H()
    var_0003 = unknown_0027H(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 2
    var_0005 = unknown_0922H(var_0004, var_0002, var_0000, var_0001)
    if var_0005 == 0 then
        add_dialogue("\"I am sorry, but thou hast overextended thy muscles. If thou couldst return at a later date, I would be quite willing to train thee.\"")
        return
    elseif var_0005 == 1 then
        var_0006 = unknown_0028H(359, 359, 644, 357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < var_0000 then
            add_dialogue("\"I regret that thou dost not seem to have the right amount of gold to train here. Mayhaps, at another time, when thy purses are more full...\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("She seems amazed.~~\"Thou art already stronger than I! I am sorry, but I cannot help thee grow any further.\"")
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
    add_dialogue(var_0008 .. " and Penni work out and spar for some time. After stretching, " .. var_0009 .. " feel" .. var_0010 .. " a335 little stronger and a bit more skilled in combat.")
    var_0011 = unknown_0910H(0, var_0002)
    if var_0011 < 30 then
        unknown_0914H(1, var_0002)
    end
    var_0012 = unknown_0910H(4, var_0002)
    if var_0012 < 30 then
        unknown_0917H(1, var_0002)
    end
    return
end