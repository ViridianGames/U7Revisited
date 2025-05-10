--- Best guess: Manages flour delivery, counting sacks and rewarding gold if sufficient.
function func_0948(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = 4
    var_0001 = 1
    add_dialogue("@Excellent! Dost thou have some flour for me?@")
    var_0002 = get_dialogue_choice() --- Guess: Gets dialogue choice
    if not var_0002 then
        add_dialogue("@No? Then thou art a -loaf-er! Ha ha ha!@")
    else
        add_dialogue("@Very good! Let me see how many sacks thou dost have...@")
        var_0003 = check_object_ownership(14, 359, 863, 357) --- Guess: Checks item ownership
        var_0004 = check_object_ownership(15, 359, 863, 357) --- Guess: Checks item ownership
        if var_0003 == 0 or var_0004 == 0 then
            add_dialogue("@But thou dost not have a single one in thy possession! Art thou trying to trick me? Get out of my shoppe!@")
            abort() --- Guess: Aborts script
        end
        var_0005 = var_0003 + math.floor(var_0004 / var_0001) * var_0000
        add_dialogue("@Beautiful flour! " .. var_0003 .. "! That means I owe thee " .. var_0005 .. " gold. Here thou art! I shall take the flour from thee now!@")
        var_0006 = add_object_to_inventory(true, 359, 644, var_0005, 359) --- Guess: Adds item to inventory
        if not var_0006 then
            add_dialogue("@If thou dost travel in a lighter fashion, thou wouldst have hands to take my gold!@")
        else
            var_0007 = remove_object_from_inventory(true, 14, 359, 863, var_0003) --- Guess: Removes item from inventory
            var_0008 = remove_object_from_inventory(true, 15, 359, 863, var_0004) --- Guess: Removes item from inventory
            add_dialogue("@Come back and work for me at any time!@")
            abort() --- Guess: Aborts script
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end