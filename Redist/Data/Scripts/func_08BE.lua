--- Best guess: Manages a strength training session, teaching weight training and combat techniques, potentially increasing strength and combat ability, with gold and experience checks.
function func_08BE(var_0000, var_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011

    var_0002 = unknown_0920H()
    if var_0002 == 0 then
        return
    end
    var_0003 = 3
    var_0004 = unknown_0922H(var_0003, var_0002, var_0000, var_0001)
    if var_0004 == 0 then
        add_dialogue("\"I am sorry, but thou dost not have enough practical experience with weights to train at this time. Perhaps in the future, when thou art ready, I could train thee.\"")
        return
    elseif var_0004 == 1 then
        var_0005 = get_party_gold()
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0005 .. " gold altogether.")
        if var_0005 < var_0000 then
            add_dialogue("\"Thou dost not have enough gold to train here.\"")
            return
        end
    end
    var_0006 = unknown_0027H(var_0002)
    if var_0002 == 356 then
        var_0007 = "you begin"
        var_0008 = "your"
    else
        var_0007 = var_0006 .. " begins"
        var_0008 = var_0006 .. "'s"
    end
    if var_0004 == 2 then
        add_dialogue("\"Thou art already as strong as I!\" he exclaims, noticing " .. var_0008 .. " muscles and build. \"Thou dost certainly know as much as I about building strong muscles.\"")
        return
    end
    var_0009 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    var_0006 = unknown_0027H(var_0002)
    add_dialogue("He begins with a short, but extensive, weight training program, followed by a sparring match with heavy weaponry. Shortly, " .. var_0007 .. " to feel stronger, and better able to utilize that strength in battle.")
    var_0010 = unknown_0910H(0, var_0002)
    if var_0010 < 30 then
        unknown_0914H(2, var_0002)
    end
    var_0011 = unknown_0910H(4, var_0002)
    if var_0011 < 30 then
        unknown_0917H(1, var_0002)
    end
    return
end