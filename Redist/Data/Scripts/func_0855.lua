--- Best guess: Manages a tavern transaction for food and drink, with quantity prompts for bulk items like jerky.
function func_0855()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    var_0000 = get_lord_or_lady() --- Guess: Gets lord/lady title
    save_answers() --- Guess: Saves current answers
    var_0001 = true
    var_0002 = {"wine", "ale", "fish", "mead", "jerky", "nothing"}
    var_0003 = {616, 616, 377, 616, 377, 0}
    var_0004 = {5, 3, 12, 0, 15, -359}
    var_0005 = {1, 2, 5, 5, 12, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" for a bottle", " for a bottle", " for one", " for a bottle", " for ten pieces", ""}
    var_0009 = {1, 1, 1, 1, 10, 0}
    add_dialogue("@\"What dost thou want for thy refreshment?\"@")
    while var_0001 do
        var_000A = select_item(var_0002) --- Guess: Selects item
        if var_000A == 1 then
            add_dialogue("@\"Fine.\"@")
            var_0001 = false
        else
            var_000B = format_price(var_0008[var_000A], var_0004[var_000A], var_0007, var_0002[var_000A], var_0006) --- Guess: Formats price
            var_000C = 0
            add_dialogue("@\"" .. var_000B .. " Art thou still interested?\"@")
            var_000D = get_dialogue_choice() --- Guess: Gets player choice
            if var_000D then
                if var_0003[var_000A] == 377 then
                    var_000B = "How many "
                    if var_0009[var_000A] > 1 then
                        var_000B = var_000B .. "packets "
                    end
                    var_000B = var_000B .. "wouldst thou like?"
                    add_dialogue("@\"" .. var_000B .. "\"@")
                    var_000C = process_purchase(true, 1, 20, var_0004[var_000A], var_0009[var_000A], var_0004[var_000A], var_0003[var_000A]) --- Guess: Processes bulk purchase
                else
                    var_000C = process_purchase(true, 1, 0, var_0004[var_000A], var_0009[var_000A], var_0004[var_000A], var_0003[var_000A]) --- Guess: Processes single purchase
                end
                if var_000C == 1 then
                    add_dialogue("@\"It is thine!\"@")
                elseif var_000C == 2 then
                    add_dialogue("@\"Thou cannot possibly carry that much!\"@")
                elseif var_000C == 3 then
                    add_dialogue("@\"Thou dost not have enough gold, " .. var_0000 .. ".\"@")
                end
                add_dialogue("@\"Wouldst thou care for something else?\"@")
                var_0001 = get_dialogue_choice() --- Guess: Continues transaction
            end
        end
    end
    restore_answers() --- Guess: Restores saved answers
end