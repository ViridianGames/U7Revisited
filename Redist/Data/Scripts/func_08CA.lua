--- Best guess: Manages an intelligence and magic training session with Perrin, teaching theoretical concepts, potentially increasing intelligence and mana, with gold and experience checks.
function func_08CA(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0002 = unknown_0920H()
    if var_0002 == 0 then
        return
    end
    var_0003 = 3
    var_0004 = unknown_0922H(var_0003, var_0002, var_0000, var_0001)
    if var_0004 == 0 then
        add_dialogue("After a few moments of questioning, he says, \"I am sorry, but thou dost not have a strong enough grasp of my theories for me to be able to instruct thee. Perhaps when thou hast had more time to study...\"")
        return
    elseif var_0004 == 1 then
        var_0005 = unknown_0028H(359, 359, 644, 357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0005 .. " gold altogether.")
        if var_0005 < var_0000 then
            add_dialogue("\"I must apologize, but I need my full fee to permit me to continue my research. Mayhaps, at another time, when thou hast more money, I can teach thee.\"")
            return
        end
    elseif var_0004 == 2 then
        add_dialogue("After a few moments of questioning, he says, \"Thou art already past my tutelage. I must humbly apologize, for there is nothing new I can teach thee.\"")
        return
    end
    var_0006 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    var_0007 = unknown_0027H(var_0002)
    if var_0002 == 356 then
        var_0008 = "You"
        var_0009 = "you"
        var_0010 = ""
        var_0011 = "have"
    else
        var_0008 = var_0007
        var_0009 = var_0007
        var_0010 = "s"
        var_0011 = "has"
    end
    add_dialogue(var_0008 .. " and Perrin dive excitedly into the pages of several tomes. Following an intensive study session, " .. var_0009 .. " find" .. var_0010 .. " the ability to comprehend and disseminate much more information than ever before. In addition, " .. var_0009 .. " " .. var_0011 .. " a better grasp of the theory behind spellcasting.")
    var_0012 = unknown_0910H(2, var_0002)
    if var_0012 < 30 then
        unknown_0916H(2, var_0002)
    end
    var_0013 = unknown_0910H(6, var_0002)
    if var_0013 < 30 then
        unknown_0918H(1, var_0002)
    end
    return
end