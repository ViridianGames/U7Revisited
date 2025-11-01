--- Best guess: Manages armor purchases (e.g., crested helm, plate armor) with dialogue and inventory checks.
function utility_unknown_1107(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"crested helm", "plate leggings", "plate armour", "great helm", "gauntlets", "chain leggings", "chain armour", "chain coif", "nothing"}
    var_0002 = {542, 576, 573, 541, 580, 575, 571, 539, 0}
    var_0003 = {60, 120, 300, 150, 20, 50, 100, 80, 0}
    var_0004 = 359
    var_0005 = {"a ", "", "", "a ", "", "", "", "a ", ""}
    var_0006 = {0, 1, 0, 0, 1, 1, 0, 0, 0}
    var_0007 = {"", " for a pair", "", "", " for a pair", " for a pair", "", "", ""}
    var_0008 = 1
    add_dialogue("@What wouldst thou like to buy?@")
    while var_0000 do
        var_0009 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@Fine.@")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0003[var_0009], var_0007[var_0009], var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " Is that acceptable?@")
            var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000C then
                var_000B = purchaseobject_(false, 1, 0, var_0003[var_0009], var_0008, var_0004) --- Guess: Purchases item
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