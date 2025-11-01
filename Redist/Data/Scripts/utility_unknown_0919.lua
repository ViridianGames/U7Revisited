--- Best guess: Manages purchase of armor (e.g., leather gloves, plate armor).
function utility_unknown_0919(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"leather gloves", "plate armour", "chain armour", "leather armour", "spiked shield", "crested helm", "nothing"}
    var_0002 = {579, 573, 571, 569, 578, 542, 0}
    var_0003 = 359
    var_0004 = {20, 300, 150, 50, 60, 75, 0}
    var_0005 = {"", "", "", "", "a ", "a ", ""}
    var_0006 = {1, 0, 0, 0, 0, 0, 0}
    var_0007 = {" for a pair", "", "", "", "", "", ""}
    var_0008 = 1
    while var_0000 do
        add_dialogue("@What wouldst thou like to buy?@")
        var_0009 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@Fine.@")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0004[var_0009], var_0007[var_0009], var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " A fair price, yes?@")
            var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000C then
                var_000B = purchase_object(false, 1, 0, var_0004[var_0009], var_0008, var_0003) --- Guess: Purchases item
            end
            if var_000B == 1 then
                add_dialogue("@Done!@")
            elseif var_000B == 2 then
                add_dialogue("@Thou cannot possibly carry that much!@")
            elseif var_000B == 3 then
                add_dialogue("@Thou dost not have enough gold for that!@")
            end
            add_dialogue("@Wouldst thou like something else?@")
            var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end