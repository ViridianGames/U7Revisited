--- Best guess: Manages a training session with Lucky, teaching sleight-of-hand tricks and potentially increasing intelligence, with gold and experience checks.
function func_08B6(var_0000, var_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011

    var_0002 = unknown_0920H()
    if var_0002 == 0 then
        return
    end
    var_0003 = 1
    var_0004 = unknown_0922H(var_0003, var_0002, var_0000, var_0001)
    if var_0004 == 0 then
        add_dialogue("\"Ah! But thou hast not the practical experience to train with me at this time! Go and experience life and return later.\"")
        return
    elseif var_0004 == 1 then
        var_0005 = unknown_0028H(359, 359, 644, 357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0005 .. " gold altogether.")
        if var_0005 < var_0000 then
            add_dialogue("\"Hmm. Thou art a little short on gold. Perhaps thou couldst visit the House of Games, win some booty, then return!\"")
            return
        end
    elseif var_0004 == 2 then
        add_dialogue("\"Thou art already as talented as I! Thou hast no need of my services!\"")
        return
    end
    var_0006 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    add_dialogue("Lucky produces a deck of cards, three sea shells and a rock, and a pair of dice. In turn, the pirate takes each item and begins to show various methods of utilizing them. He shows how to deal cards from the bottom of the deck, and how to do a false shuffle. With the shells and rock, he shows lightning-fast maneuvers which hide the rock under one of the shells, the one it couldn't possibly be under. Finally, he shows how to use saliva to weight the dice so that they always turn up lucky.")
    if var_0002 == 356 then
        var_0007 = unknown_0931H(0, 359, 955, 1, 357)
        if var_0007 then
            var_0008 = "happily hands you back your Ankh, which had "
            var_0009 = "managed to slip from around your neck during "
            var_0010 = "the session."
        else
            var_0008 = "happily holds out his hand to shake yours, "
            var_0009 = "but pulls it away quickly when you proceed "
            var_0010 = "to do so."
        end
        add_dialogue("When the training session is over, Lucky " .. var_0008 .. var_0009 .. var_0010)
    end
    var_0011 = unknown_0910H(2, var_0002)
    if var_0011 < 30 then
        unknown_0916H(1, var_0002)
    end
    return
end