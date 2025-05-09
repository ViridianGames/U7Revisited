--- Best guess: Handles a weapon shop transaction, with bulk purchase options for items like bolts and arrows.
function func_0858()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    save_answers() --- Guess: Saves current answers
    var_0000 = true
    var_0001 = {"bolts", "arrows", "halberd", "sword", "bow", "dagger", "club", "nothing"}
    var_0002 = {723, 722, 603, 599, 597, 594, 590, 0}
    var_0003 = -359
    var_0004 = {30, 25, 250, 100, 40, 20, 20, 0}
    var_0005 = {"", "", "a ", "a ", "a ", "a ", "a ", ""}
    var_0006 = {1, 1, 0, 0, 0, 0, 0, 0}
    var_0007 = {" per dozen", " per dozen", "", "", "", "", "", ""}
    var_0008 = {12, 12, 1, 1, 1, 1, 1, 0}
    add_dialogue("@\"What wouldst thou like to buy?\"@")
    while var_0000 do
        var_0009 = select_item(var_0001) --- Guess: Selects item
        if var_0009 == 1 then
            add_dialogue("@\"Tsk tsk... I am broken-hearted...\"@")
            var_0000 = false
        else
            var_000A = format_price(var_0007[var_0009], var_0004[var_0009], var_0006[var_0009], var_0001[var_0009], var_0005[var_0009]) --- Guess: Formats price
            var_000B = 0
            add_dialogue("@\"" .. var_000A .. " Art thou still interested?\"@")
            var_000C = get_dialogue_choice() --- Guess: Gets player choice
            if var_000C then
                if var_0002[var_0009] == 722 or var_0002[var_0009] == 723 then
                    add_dialogue("@\"How many dozen wouldst thou like?\"@")
                    var_000B = process_purchase(true, 1, 5, var_0004[var_0009], var_0008[var_0009], var_0003, var_0002[var_0009]) --- Guess: Processes bulk purchase
                else
                    var_000B = process_purchase(false, 1, 0, var_0004[var_0009], var_0008[var_0009], var_0003, var_0002[var_0009]) --- Guess: Processes single purchase
                end
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