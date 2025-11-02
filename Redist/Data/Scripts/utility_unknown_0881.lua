--- Best guess: Handles purchase of food/drink items (e.g., wine, jerky), with a flag check for silverleaf availability.
function utility_unknown_0881(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    var_0000 = get_player_name() --- Guess: Gets player name
    save_answers() --- Guess: Saves dialogue answers
    var_0001 = true
    var_0002 = {"wine", "ale", "silverleaf", "ham", "fish", "mead", "jerky", "nothing"}
    var_0003 = {616, 616, 377, 377, 377, 616, 377, 0}
    var_0004 = {5, 3, 31, 11, 13, 0, 15, 359}
    var_0005 = {2, 2, 20, 10, 3, 5, 25, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" for a bottle", " for a bottle", " for a plateful", " for one slice", " each", " for a bottle", " for ten pieces", ""}
    var_0009 = {1, 1, 1, 1, 1, 1, 10, 0}
    while var_0001 do
        add_dialogue("@What wouldst thou like?@")
        var_000A = show_purchase_options(var_0002) --- Guess: Shows purchase options
        if var_000A == 1 then
            add_dialogue("@Very well.@")
            var_0001 = false
        elseif var_000A == 6 and not get_flag(299) then
            add_dialogue("@I have no more. For some reason, no one is sending Silverleaf to us...@")
        else
            var_000B = format_price_message(var_0002[var_000A], var_0005[var_000A], var_0008[var_000A], var_0006) --- Guess: Formats price message
            var_000C = 0
            add_dialogue("@^" .. var_000B .. " Is that all right?@")
            var_000D = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000D then
                var_000B = "How many "
                if var_0009[var_000A] > 1 then
                    var_000B = var_000B .. "sets "
                end
                var_000B = var_000B .. "wouldst thou like?"
                add_dialogue("@^" .. var_000B .. "@")
                var_000C = purchase_object(true, 1, 20, var_0005[var_000A], var_0009[var_000A], var_0004[var_000A]) --- Guess: Purchases item
            end
            if var_000C == 1 then
                add_dialogue("@Done!@")
            elseif var_000C == 2 then
                add_dialogue("@But, " .. var_0000 .. ", thou cannot possibly carry that much!@")
            elseif var_000C == 3 then
                add_dialogue("@I am sorry, " .. var_0000 .. ", thou hast not enough gold for that.@")
            end
            add_dialogue("@Wouldst thou like something else?@")
            var_0001 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end