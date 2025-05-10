--- Best guess: Manages purchase of weapons (e.g., 2-handed sword, dagger).
function func_0898(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"2-handed sword", "2-handed axe", "throwing axe", "sword", "mace", "spear", "dagger", "sling", "nothing"}
    var_0002 = {602, 601, 593, 599, 659, 592, 594, 474, 0}
    var_0003 = 359
    var_0004 = {250, 100, 25, 100, 20, 25, 20, 20, 0}
    var_0005 = {"a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", ""}
    var_0006 = {1, 1, 0, 0, 0, 0, 0, 0, 0}
    var_0007 = {"", "", "", "", "", "", "", "", ""}
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 1, 0}
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
                if var_0002[var_0009] == 722 or var_0002[var_0009] == 723 then
                    add_dialogue("@How many dozen wouldst thou like?@")
                    var_000B = purchaseobject_(true, 1, 5, var_0004[var_0009], var_0008[var_0009], var_0003) --- Guess: Purchases item
                else
                    var_000B = purchaseobject_(false, 1, 0, var_0004[var_0009], var_0008[var_0009], var_0003) --- Guess: Purchases item
                end
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