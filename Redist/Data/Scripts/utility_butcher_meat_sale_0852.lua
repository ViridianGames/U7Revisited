--- Best guess: Manages a meat-selling transaction with a butcher, checking inventory and gold, part of the game's economy system.
function utility_unknown_0852()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    var_0000 = get_lord_or_lady() --- Guess: Gets lord/lady title
    add_dialogue("@\"How many portions wouldst thou wish to sell?\"@")
    var_0001 = ask_number(0, 1, 10, 0) --- Guess: Prompts for number of portions
    if var_0001 == 0 then
        add_dialogue("@\"Oh, my. We truly do need the meat. Well, perhaps next time.\"@")
    else
        var_0002 = check_object_ownership(8, -359, 377, -357) --- Guess: Checks meat in inventory
        if var_0002 < var_0001 then
            add_dialogue("@\"Thou cannot sell me what thou dost not have! Now, truly...!\"@")
            -- TODO goto start --- Guess: Restarts transaction
        end
        add_dialogue("@\"Excellent! I accept the trade, " .. var_0000 .. ". Here is thy gold.\"@")
        var_0003 = var_0001 * 5 --- Guess: Calculates gold (5 per portion)
        var_0004 = add_object_to_inventory(-359, -359, 644, var_0003) --- Guess: Adds gold to inventory
        if not var_0004 then
            add_dialogue("@\"Oh, dear. Thou cannot possibly carry this much gold! Perhaps thou mayest return when thou hast dropped something else.\"@")
        else
            var_0005 = remove_object_from_inventory(8, -359, 377, var_0001) --- Guess: Removes meat from inventory
        end
    end
end