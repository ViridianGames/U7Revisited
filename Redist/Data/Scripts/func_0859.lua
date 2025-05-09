--- Best guess: Manages an armor shop transaction, with single-item purchases for items like gauntlets and plate armor.
function func_0859()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    save_answers() --- Guess: Saves current answers
    var_0000 = true
    var_0001 = {"gauntlets", "scale armour", "gorget", "plate leggings", "plate armour", "great helm", "nothing"}
    var_0002 = {580, 570, 586, 576, 573, 541, 0}
    var_0003 = -359
    var_0004 = {25, 100, 40, 200, 325, 200, 0}
    var_0005 = {"", "", "a ", "", "", "a ", ""}
    var_0006 = {1, 0, 0, 1, 0, 0, 0}
    var_0007 = {" for a pair", "", "", " for a pair", "", "", ""}
    var_0008 = 1
    add_dialogue("@\"What wouldst thou like to buy?\"@")
    while var_0000 do
        var_0009 = select_item(var_0001) --- Guess: Selects item
        if var_0009 == 1 then
            add_dialogue("@\"Tsk tsk... I am broken-hearted...\"@")
            var_0000 = false
        else
            var_000A = format_price(var_0007[var_0009], var_0004[var_0009], var_0006[var_0009], var_0001[var_0009], var_0005[var_0009]) --- Guess: Formats price
            var_000B = 0
            add_dialogue("@\"" .. var_000A .. " Is that acceptable?\"@")
            var_000C = get_dialogue_choice() --- Guess: Gets player choice
            if var_000C then
                var_000B = process_purchase(false, 1, 0, var_0004[var_0009], var_0008, var_0003, var_0002[var_0009]) --- Guess: Processes single purchase
                if var_000B == 1 then
                    add_dialogue("@\"Done!\"@")
                elseif var_000B == 2 then
                    add_dialogue("@\"Thou cannot possibly carry that much!\"@")
                elseif var_000B == 3 then
                    add_dialogue("@\"Thou dost not have enough gold for that!\"@")
                end
                add_dialogue("@\"Wouldst thou like something else?\"@")
                var_0000 = get_dialogue_choice() --- Guess: Continues transaction
            end
        end
    end
    restore_answers() --- Guess: Restores saved answers
end