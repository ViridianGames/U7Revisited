--- Best guess: Manages a training session with Lucky, teaching sleight-of-hand tricks and potentially increasing intelligence, with gold and experience checks.
---@param training_cost integer The gold cost for the training session
---@param max_stat_value integer The maximum stat value allowed for training
function utility_unknown_0950(training_cost, max_stat_value)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011

    var_0002 = utility_unknown_1056()
    if var_0002 == 0 then
        return
    end
    var_0003 = 1
    var_0004 = utility_unknown_1058(var_0003, var_0002, training_cost, max_stat_value)
    if var_0004 == 0 then
        add_dialogue("\"Ah! But thou hast not the practical experience to train with me at this time! Go and experience life and return later.\"")
        return
    elseif var_0004 == 1 then
        var_0005 = get_party_gold()
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0005 .. " gold altogether.")
        if var_0005 < training_cost then
            add_dialogue("\"Hmm. Thou art a little short on gold. Perhaps thou couldst visit the House of Games, win some booty, then return!\"")
            return
        end
    elseif var_0004 == 2 then
        add_dialogue("\"Thou art already as talented as I! Thou hast no need of my services!\"")
        return
    end
    var_0006 = remove_party_items(true, 359, 359, 644, training_cost)
    add_dialogue("You pay " .. training_cost .. " gold, and the training session begins.")
    add_dialogue("Lucky produces a deck of cards, three sea shells and a rock, and a pair of dice. In turn, the pirate takes each item and begins to show various methods of utilizing them. He shows how to deal cards from the bottom of the deck, and how to do a false shuffle. With the shells and rock, he shows lightning-fast maneuvers which hide the rock under one of the shells, the one it couldn't possibly be under. Finally, he shows how to use saliva to weight the dice so that they always turn up lucky.")
    if var_0002 == 356 then
        var_0007 = utility_unknown_1073(0, 359, 955, 1, 357)
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
    var_0011 = utility_unknown_1040(2, var_0002)
    if var_0011 < 30 then
        utility_unknown_1046(1, var_0002)
    end
    return
end