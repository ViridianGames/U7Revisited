--- Best guess: Handles tavern item purchases (e.g., ale, wine, Silverleaf), with a flag-based unavailability message for Silverleaf.
function utility_unknown_1105()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    var_0000 = utility_unknown_1033() --- External call to get lord or lady title
    save_answers() --- Guess: Saves dialogue answers
    var_0001 = true
    var_0002 = {"ale", "wine", "cake", "Silverleaf", "trout", "mead", "bread", "mutton", "nothing"}
    var_0003 = {616, 616, 377, 377, 377, 616, 377, 377, 0}
    var_0004 = {3, 5, 5, 31, 12, 0, 1, 8, 359}
    var_0005 = {2, 3, 2, 30, 3, 7, 2, 3, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" for one bottle", " for one bottle", " for one slice", " for one portion", " for one portion", " for one bottle", " for one loaf", " for one portion", ""}
    var_0009 = 1
    add_dialogue("@What wouldst thou like?@")
    while var_0001 do
        var_000A = show_purchase_options(var_0002) --- Guess: Shows purchase options
        if var_000A == 1 then
            add_dialogue("@Fine.@")
            var_0001 = false
        elseif var_000A == 6 and get_flag(299) then
            add_dialogue("@I regret to tell thee that this fine establishment will no longer be able to provide our fine customers with Silverleaf. The person who provides me with the delicate meal is no longer able to procure it. I am dreadfully sorry, " .. var_0000 .. ".@")
        else
            var_000B = format_price_message(var_0002[var_000A], var_0005[var_000A], var_0007, var_0006) --- Guess: Formats price message
            var_000C = 0
            add_dialogue("@^" .. var_000B .. " That is a fair price, is it not?@")
            var_000D = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000D then
                if var_0003[var_000A] == 377 then
                    add_dialogue("@How many wouldst thou like?@")
                    var_000C = purchase_object(true, 1, 20, var_0005[var_000A], var_0009, var_0004[var_000A]) --- Guess: Purchases item
                else
                    var_000C = purchase_object(true, 1, 0, var_0005[var_000A], var_0009, var_0004[var_000A]) --- Guess: Purchases item
                end
            end
            if var_000C == 1 then
                add_dialogue("@Done!@")
            elseif var_000C == 2 then
                add_dialogue("@Thou cannot possibly carry that much!@")
            elseif var_000C == 3 then
                add_dialogue("@Thou dost not have enough gold for that!@")
            end
            add_dialogue("@Wouldst thou like something else?@")
            var_0001 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end