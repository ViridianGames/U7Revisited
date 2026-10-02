--- Best guess: Manages a dialogue for exchanging eggs for gold, checking the player's inventory and handling payment or rejection.
function utility_unknown_0952()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    save_answers()
    var_0000 = 1
    var_0001 = 1
    add_dialogue("\"Excellent! Dost thou have some eggs for me?\"")
    var_0002 = ask_yes_no()
    if not var_0002 then
        add_dialogue("\"Very good! Let me see how many thou dost have...\"")
        var_0003 = count_objects(24, 359, 377, 357)
        if var_0003 == 0 then
            add_dialogue("\"But thou dost not have a single one in thy possession! Thou dost waste my time!\"")
            return
        end
        var_0004 = var_0003 / var_0001 * var_0000
        add_dialogue("\"Lovely! " .. var_0003 .. "! That means I owe thee " .. var_0004 .. " gold. Here thou art! I shall take the eggs from thee now!\"")
        var_0005 = add_party_items(true, 359, 359, 644, var_0004)
        if var_0005 then
            var_0006 = remove_party_items(true, 24, 359, 377, var_0003)
            add_dialogue("\"Come back and work for me at any time!\"")
            return
        else
            add_dialogue("\"If thou wouldst travel in a lighter fashion, thou wouldst have hands to take my gold!\"")
        end
    else
        add_dialogue("\"No? What hast thou been doing with my chickens? Art thou some kind of fowl pervert?\"")
    end
    restore_answers()
    return
end