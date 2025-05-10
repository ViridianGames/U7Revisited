--- Best guess: Manages weapon purchases (e.g., 2-handed axe, dagger) with dialogue and inventory checks.
function func_0952(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    var_0000 = true
    var_0001 = {"2-handed axe", "2-handed sword", "sword", "mace", "dagger", "throwing axe", "nothing"}
    var_0002 = {601, 602, 599, 659, 594, 593, 0}
    var_0003 = {70, 125, 70, 15, 12, 20, 0}
    add_dialogue("@What wouldst thou like to buy?@")
    while var_0000 do
        var_0004 = show_purchase_options(var_0001) --- Guess: Shows purchase options
        if var_0004 == 1 then
            add_dialogue("@Fine.@")
            var_0000 = false
        else
            var_0005 = "a "
            var_0006 = 359
            var_0007 = ""
            var_0008 = 1
            var_0009 = format_price_message(var_0001[var_0004], var_0003[var_0004], var_0007, var_0005) --- Guess: Formats price message
            var_000A = 0
            add_dialogue("@^" .. var_0009 .. " Wilt thou buy it at that price?@")
            var_000B = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_000B then
                var_000A = purchaseobject_(true, 1, 0, var_0003[var_0004], var_0008, var_0006) --- Guess: Purchases item
            end
            if var_000A == 1 then
                add_dialogue("@Done!@")
            elseif var_000A == 2 then
                add_dialogue("@Thou cannot possibly carry that much!@")
            elseif var_000A == 3 then
                add_dialogue("@Thou dost not have enough gold for that!@")
            end
            add_dialogue("@Wouldst thou like something else?@")
            var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end