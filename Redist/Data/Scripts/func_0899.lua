--- Best guess: Manages purchase of tools (e.g., bucket, shovel).
function func_0899(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"bucket", "hoe", "lockpick", "powder keg", "shovel", "bag", "backpack", "oil flasks", "torch", "nothing"}
    var_0002 = {810, 626, 627, 704, 625, 802, 801, 782, 595, 0}
    var_0003 = 359
    var_0004 = {8, 20, 10, 35, 20, 8, 15, 72, 5, 0}
    var_0005 = {"a ", "a ", "a ", "a ", "a ", "a ", "a ", "", "a ", ""}
    var_0006 = {0, 0, 0, 0, 0, 0, 0, 1, 0, 0}
    var_0007 = {"", "", "", "", "", "", "", " for a dozen", "", ""}
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    while var_0000 do
        add_dialogue("@What wouldst thou like to buy?@")
        var_0009 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@Fine.@")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0004[var_0009], var_0007[var_0009], var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " That is a fair price, is it not?@")
            var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000C then
                if var_0002[var_0009] == 782 or var_0002[var_0009] == 595 or var_0002[var_0009] == 627 then
                    if var_0002[var_0009] == 782 then
                        add_dialogue("@How many sets of twelve wouldst thou like?@")
                    else
                        add_dialogue("@How many wouldst thou like?@")
                    end
                    var_000B = purchaseobject_(true, 1, 20, var_0004[var_0009], var_0008[var_0009], var_0003) --- Guess: Purchases item
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