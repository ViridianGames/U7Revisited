--- Best guess: Manages purchase of weapons (e.g., bolts, sword).
function func_0872(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E
    debug_print("Started 0872")
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"bolts - 15 gold for a dozen", "arrows - 10 gold for a dozen", "bow", "sling - 30 gold", "club - 10 gold", "2-handed sword - 80 gold", "2-handed hammer - 60 gold", "sword - 50 gold", "mace - 15 gold", "dagger - 10 gold", "nothing"}
    var_0002 = {723, 722, 597, 474, 590, 602, 600, 599, 659, 594, 0}
    var_0003 = 359
    var_0004 = {15, 10, 30, 10, 15, 80, 60, 50, 15, 10, 0}
    var_0005 = {"", "", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", ""}
    var_0006 = {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    var_0007 = {" for a dozen", " for a dozen", "", "", "", "", "", "", "", "", ""}
    var_0008 = {12, 12, 1, 1, 1, 1, 1, 1, 1, 1, 0}
    --while var_0000 do
        --coroutine.yield()
        --add_dialogue("\"What wouldst thou like to buy?\"")
        var_0009 = get_purchase_option({"\"What wouldst thou like to buy?\"", "bolts - 15 gold for a dozen", "arrows - 10 gold for a dozen", "bow - 30 gold", "sling - 10 gold", "club - 15 gold", "2-handed sword - 80 gold", "2-handed hammer - 60 gold", "sword - 50 gold", "mace - 15 gold", "dagger - 10 gold", "nothing"})
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_000A = format_price_message(var_0001[var_0009], var_0004[var_0009], var_0007[var_0009], var_0005[var_0009]) --- Guess: Formats price message
            var_000B = 0
            add_dialogue("@^" .. var_000A .. " Is that acceptable?@")
            if var_0002[var_0009] == 722 or var_0002[var_0009] == 723 then
                var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_000C then
                    add_dialogue("@How many sets wouldst thou like?@")
                    var_000B = purchaseobject_(true, 1, 20, var_0004[var_0009], var_0008[var_0009], var_0003) --- Guess: Purchases item
                end
            else
                var_000D = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_000D then
                    var_000B = purchaseobject_(false, 1, 0, var_0004[var_0009], var_0008[var_0009], var_0003) --- Guess: Purchases item
                end
            end
            if var_000B == 1 then
                add_dialogue("\"Very good. At last we are getting somewhere!\"")
            elseif var_000B == 2 then
                add_dialogue("\"Thou hast thine hands full, idiot!\"")
            elseif var_000B == 3 then
                add_dialogue("\"Thou hast a lot of gall attempting to buy something...\"")
            end
            --add_dialogue("\"Anything else for thee today?\"")
            --var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    --end
    restore_answers() --- Guess: Restores dialogue answers
end