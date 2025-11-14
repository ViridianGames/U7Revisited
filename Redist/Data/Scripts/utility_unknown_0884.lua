--- Best guess: Manages purchase of adventuring gear (e.g., bedroll, torch).
function utility_unknown_0884()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"bedroll", "swamp boots", "bucket", "lockpicks", "backpack", "torch", "nothing"}
    var_0002 = {583, 588, 810, 627, 801, 595, 0}
    var_0003 = 359
    var_0004 = {15, 40, 2, 8, 12, 4, 0}
    var_0005 = {"a ", "a pair of ", "a ", "some ", "a ", "a ", "a "}
    var_0006 = {0, 1, 0, 1, 0, 0, 0}
    var_0007 = ""
    var_0008 = 1
    while var_0000 do
        add_dialogue("@What wouldst thou like to buy?@")
        var_0009 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0009 == 1 then
            add_dialogue("@Fine.@")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0004[var_0009], var_0007, var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " Is that acceptable?@")
            if var_0002[var_0009] == 627 or var_0002[var_0009] == 595 then
                var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_000C then
                    add_dialogue("@How many wouldst thou like?@")
                    var_000B = purchase_object(true, 1, 5, var_0004[var_0009], var_0008, var_0003) --- Guess: Purchases item
                end
            else
                var_000D = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_000D then
                    var_000B = purchase_object(false, 1, 0, var_0004[var_0009], var_0008, var_0003) --- Guess: Purchases item
                end
            end
            if var_000B == 1 then
                add_dialogue("@Very good. At last we are getting somewhere!@")
            elseif var_000B == 2 then
                add_dialogue("@Thou hast thine hands full, idiot!@")
            elseif var_000B == 3 then
                add_dialogue("@Thou hast a lot of gall attempting to buy something...@")
            end
            add_dialogue("@Anything else for thee today?@")
            var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end