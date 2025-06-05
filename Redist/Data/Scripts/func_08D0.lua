--- Best guess: Manages a training session with Rayburt, teaching meditation and combat techniques, potentially increasing dexterity, intelligence, and combat ability, with gold and experience checks.
function func_08D0(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0002 = unknown_0920H()
    var_0003 = unknown_090FH(var_0002)
    var_0004 = "feels"
    var_0005 = get_player_name()
    if var_0003 == var_0005 then
        var_0003 = "you"
        var_0006 = "you"
        var_0004 = "feel"
    elseif var_0002 == -8 or var_0002 == -5 or var_0002 == -9 then
        var_0006 = "her"
    else
        var_0006 = "him"
    end
    if var_0002 == 0 then
        return
    end
    var_0007 = 3
    var_0008 = unknown_0922H(var_0007, var_0002, var_0000, var_0001)
    if var_0008 == 0 then
        add_dialogue("\"I am sorry, but thou dost not have enough experience to train at this time. Return at a later date and I would be most happy to lead a session.\"")
        return
    elseif var_0008 == 1 then
        var_0009 = unknown_0028H(359, 359, 644, 357)
        if var_0009 < var_0000 then
            add_dialogue("\"It seems that thou hast not enough gold. Do return when thou art a bit wealthier.\"")
            return
        end
    elseif var_0008 == 2 then
        add_dialogue("\"I am amazed! Thou art already as experienced as I! Thou cannot be trained further by me.\"")
        return
    end
    var_0010 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("Rayburt takes your money. \"The session shall begin.\"")
    add_dialogue("Rayburt first instructs " .. var_0003 .. " to lie on the floor and relax. He teaches " .. var_0006 .. " breathing exercises and techniques with which to cleanse the mind of all thoughts.")
    add_dialogue("After a while, he asks " .. var_0006 .. " to stand up and illustrates balance and control, relating it to meditation and concentration.")
    add_dialogue("Finally, he demonstrates several good moves involving hand-to-hand combat, and combat using a sword. By the end of the hour, " .. var_0003 .. " " .. var_0004 .. " much more knowledgeable and proficient in this unusual form of fighting.")
    var_0011 = unknown_0910H(1, var_0002)
    var_0012 = unknown_0910H(2, var_0002)
    var_0013 = unknown_0910H(4, var_0002)
    if var_0011 < 30 then
        unknown_0915H(1, var_0002)
    end
    if var_0012 < 30 then
        unknown_0916H(1, var_0002)
    end
    if var_0013 < 30 then
        unknown_0917H(1, var_0002)
    end
    return
end