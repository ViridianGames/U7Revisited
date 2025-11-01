--- Best guess: Handles potion purchase with flag-based pricing adjustments and dialogue.
function utility_unknown_1097(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"orange potion", "red potion", "purple potion", "blue potion", "nothing"}
    var_0002 = {340, 340, 340, 340, 0}
    var_0003 = {4, 2, 5, 0, 359}
    var_0004 = {10, 150, 150, 30, 0}
    var_0005 = {45, 600, 600, 120, 0}
    var_0006 = {"a ", "a ", "a ", "a ", ""}
    var_0007 = 0
    var_0008 = ""
    var_0009 = 1
    add_dialogue("@To want what item?@")
    while var_0000 do
        var_000A = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_000A == 1 then
            if get_flag(3) then
                add_dialogue("@To be good. To want to sell nothing to you.@")
            else
                add_dialogue("@To understand.@")
            end
            var_0000 = false
        else
            if get_flag(3) then
                var_000B = var_0005[var_000A]
                var_000C = format_price_message(var_0001[var_000A], var_000B, var_0007, var_0008) --- Guess: Formats price message
            else
                var_000B = adjust_potion_price(var_0004[var_000A]) --- Guess: Adjusts potion price
                var_000C = format_price_message(var_0001[var_000A], var_000B, var_0007, var_0006[var_000A]) --- Guess: Formats price message
            end
            var_000D = 0
            add_dialogue("@^" .. var_000C .. " To accept the price?@")
            var_000E = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000E then
                var_000D = purchaseobject_(false, 1, 0, var_000B, var_0009, var_0003[var_000A]) --- Guess: Purchases item
            end
            if var_000D == 1 then
                add_dialogue("@To be agreed!@")
            elseif var_000D == 2 then
                add_dialogue("@To be unable to carry that much, human!@")
            elseif var_000D == 3 then
                add_dialogue("@To have not enough gold for that!@")
            end
            add_dialogue("@To want something else?@")
            var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end