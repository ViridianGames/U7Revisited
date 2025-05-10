--- Best guess: Handles purchase of provisions (e.g., milk, mutton rations).
function func_0876(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    var_0000 = get_player_name() --- Guess: Gets player name
    save_answers() --- Guess: Saves dialogue answers
    var_0001 = true
    var_0002 = {"milk", "ale", "wine", "mead", "cheese", "grapes", "cake", "ham", "trout", "bread", "mutton rations", "nothing"}
    var_0003 = {616, 616, 616, 616, 377, 377, 377, 377, 377, 377, 377, 0}
    var_0004 = {7, 3, 5, 0, 26, 19, 5, 11, 12, 0, 15, 359}
    var_0005 = {4, 2, 5, 10, 3, 3, 1, 15, 3, 6, 16, 0}
    var_0006 = {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0}
    var_0007 = {" for a bottle", " for a bottle", " for a bottle", " for a bottle", " for a hunk", " for a bunch", " for one piece", " for one slice", " for one portion", " for one loaf", " for 10 pieces", ""}
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 0}
    while var_0001 do
        add_dialogue("@What wouldst thou choose to buy, " .. var_0000 .. "?@")
        var_0009 = show_purchase_options(var_0002) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@Very well, " .. var_0000 .. ".@")
            var_0001 = false
        else
            var_000A = ""
            var_000B = 0
            var_000C = format_price_message(var_0002[var_0009], var_0005[var_0009], var_0007[var_0009], var_000A) --- Guess: Formats price message
            add_dialogue("@^" .. var_000C .. ". Dost thou find the price acceptable?@")
            var_000D = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000D then
                if var_0003[var_0009] == 616 then
                    var_000B = purchaseobject_(true, 1, 0, var_0005[var_0009], var_0008[var_0009], var_0004[var_0009]) --- Guess: Purchases item
                else
                    add_dialogue("@How many dost thou want to purchase?@")
                    var_000B = purchaseobject_(true, 1, 20, var_0005[var_0009], var_0008[var_0009], var_0004[var_0009]) --- Guess: Purchases item
                end
            end
            if var_000B == 1 then
                add_dialogue("@Very good, " .. var_0000 .. ".@")
            elseif var_000B == 2 then
                add_dialogue("@I believe thou cannot carry that much, " .. var_0000 .. ".@")
            elseif var_000B == 3 then
                add_dialogue("@It would appear thou dost not have enough gold for that!@")
            end
            add_dialogue("@Wouldst thou care to buy something else?@")
            var_0001 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end