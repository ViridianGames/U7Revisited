--- Best guess: Manages purchase of provisions (e.g., wine, cheese) with a unique dialogue style.
function func_0889(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"wine", "ale", "mead", "milk", "grapes", "cheese", "bread", "ham", "flounder", "jerky", "nothing"}
    var_0002 = {616, 616, 616, 616, 377, 377, 377, 377, 377, 377, 0}
    var_0003 = {5, 3, 0, 7, 19, 27, 0, 11, 13, 15, 359}
    var_0004 = {2, 1, 7, 3, 1, 3, 1, 9, 2, 12, 0}
    var_0005 = {"", "", "", "", "", "", "", "", "", "", ""}
    var_0006 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    var_0007 = {" for a bottle", " for a bottle", " for a bottle", " for a bottle", " for a bunch", " per wedge", " for a loaf", " for a slice", " for one portion", " for ten pieces", ""}
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 0}
    while var_0000 do
        add_dialogue("@To desire what item?@")
        var_0009 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@To understand.@")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0004[var_0009], var_0007[var_0009], var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " To agree to the price?@")
            var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000C then
                if var_0002[var_0009] == 616 then
                    var_000B = purchase_item(true, 1, 0, var_0004[var_0009], var_0008[var_0009], var_0003[var_0009]) --- Guess: Purchases item
                else
                    add_dialogue("@To request how many?@")
                    var_000B = purchase_item(true, 1, 20, var_0004[var_0009], var_0008[var_0009], var_0003[var_0009]) --- Guess: Purchases item
                end
            end
            if var_000B == 1 then
                add_dialogue("@To be done!@")
            elseif var_000B == 2 then
                add_dialogue("@To carry too much already!@")
            elseif var_000B == 3 then
                add_dialogue("@To be without enough gold!@")
            end
            add_dialogue("@To request something else?@")
            var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end