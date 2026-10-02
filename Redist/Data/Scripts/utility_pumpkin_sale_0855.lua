--- Best guess: Processes a pumpkin-selling transaction, checking inventory and rewarding gold.
function utility_unknown_0855()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    save_answers() --- Guess: Saves current answers
    var_0000 = 1
    var_0001 = 1
    add_dialogue("@\"Excellent! Hast thou brought some pumpkins for me?\"@")
    var_0002 = get_dialogue_choice() --- Guess: Gets player choice
    if not var_0002 then
        add_dialogue("@\"Very good! Let me see how many thou dost have...\"@")
        var_0003 = check_object_ownership(20, -359, 377, -357) --- Guess: Checks pumpkins (frame 20)
        var_0004 = check_object_ownership(21, -359, 377, -357) --- Guess: Checks pumpkins (frame 21)
        var_0005 = var_0003 + var_0004 --- Guess: Total pumpkins
        if var_0005 == 0 then
            add_dialogue("@\"But thou dost not have a single one in thy possession! Thou art as looney as Mack!\"@")
            abort() --- Guess: Aborts script
        else
            var_0006 = var_0005 / var_0001 * var_0000 --- Guess: Calculates gold
            add_dialogue("@\"Lovely! " .. var_0005 .. "! That means I owe thee " .. var_0006 .. " gold. Here thou art! I shall take the pumpkins from thee now!\"@")
            var_0007 = add_object_to_inventory(-359, -359, 644, var_0006) --- Guess: Adds gold
            if not var_0007 then
                var_0008 = remove_object_from_inventory(20, -359, 377, var_0003) --- Guess: Removes pumpkins (frame 20)
                var_0008 = remove_object_from_inventory(21, -359, 377, var_0004) --- Guess: Removes pumpkins (frame 21)
                add_dialogue("@\"Come back and work for me at any time!\"@")
                abort() --- Guess: Aborts script
            else
                add_dialogue("@\"If thou wouldst travel in a lighter fashion, thou wouldst have hands to take my gold!\"@")
            end
        end
    else
        add_dialogue("@\"No? What hast thou been doing in my field? Thou art as worthless as most of the workers one finds!\"@")
    end
    restore_answers() --- Guess: Restores saved answers
end