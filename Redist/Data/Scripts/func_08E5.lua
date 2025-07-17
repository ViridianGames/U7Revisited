--- Best guess: Manages a combat training session with Sentri, teaching sword techniques, potentially increasing dexterity, with gold and experience checks.
function func_08E5(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0002 = unknown_0921H()
    var_0003 = (var_0002 == -8 or var_0002 == -5 or var_0002 == -9)
    if var_0002 == 0 then
        return
    end
    var_0004 = 1
    var_0005 = unknown_0922H(var_0004, var_0002, var_0000, var_0001)
    if var_0005 == 0 then
        add_dialogue("\"I am sorry, but thou dost not have enough practical experience to train at this time. Return another day after thou hast slain a few more creatures.\"")
        return
    elseif var_0005 == 1 then
        var_0006 = get_party_gold()
        if var_0006 < var_0000 then
            add_dialogue("\"I regret that thou dost not seem to have enough gold to train here. Mayhaps at another time, when thy fortunes are more prosperous.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("\"Thou art already as proficient as I! I am afraid that thou cannot be trained further by me!\"")
        return
    end
    var_0007 = unknown_002BH(true, 359, 359, 644, var_0000)
    var_0008 = unknown_0027H(var_0002)
    if var_0002 == 356 then
        var_0008 = "you"
        var_0009 = "are"
        var_0010 = "have"
        var_0011 = "you"
        var_0012 = "your"
        var_0013 = "manage"
    elseif var_0003 then
        var_0008 = "she"
        var_0011 = "her"
        var_0012 = "her"
    else
        var_0008 = "he"
        var_0011 = "him"
        var_0012 = "his"
    end
    if not var_0003 then
        var_0009 = "is"
        var_0010 = "has"
        var_0013 = "manages"
    end
    add_dialogue("\"On guard!\" Sentri cries as he draws his sword. " .. var_0008 .. " " .. var_0009 .. " forced to respond with the most easily readied weapon " .. var_0008 .. ". Without a word, Sentri advances upon " .. var_0011 .. ", swinging his blade in a seemingly wild, yet entirely controlled manner. " .. var_0008 .. " " .. var_0009 .. " forced to block his blows to the best of " .. var_0012 .. " ability. Luckily, Sentri stops just short of striking " .. var_0011 .. ", which he is often able to do. Slowly but surely, over the course of the training session, " .. var_0012 .. " blocking improves and " .. var_0008 .. " " .. var_0013 .. " to get in a few thrusts of " .. var_0012 .. " own. " .. var_0012 .. " agility improves, and the improvement is tangibly perceptible.")
    add_dialogue("\"I enjoyed that!\" Sentri exclaims after it is all over.")
    var_0014 = unknown_0910H(1, var_0002)
    if var_0014 < 30 then
        unknown_0915H(1, var_0002)
    end
    return
end