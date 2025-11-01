--- Best guess: Manages a shop interaction for lockpicks and torches, with price and quantity validation, handling inventory and gold checks, with flag-based dialogue variations.
function utility_shop_0858()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    if not get_flag(694) then
        var_0001 = {"lockpick", "torch", "nothing"}
        var_0002 = {627, 595, 0}
        var_0003 = {-359, -359, -359}
        var_0004 = {1, 5, 0}
        var_0005 = {"a ", "a ", ""}
        var_0006 = 0
        var_0007 = ""
        var_0008 = 1
    else
        var_0001 = {"Lockpick", "Torch", "Nothing"}
        var_0002 = {627, 595, 0}
        var_0003 = {-359, -359, -359}
        var_0004 = {10, 5, 0}
        var_0005 = {"a ", "a ", ""}
        var_0006 = 0
        var_0007 = ""
        var_0008 = 1
    end
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Tsk tsk... I am broken-hearted...\"")
            var_0000 = false
        else
            var_000A = utility_shop_1051(var_0007, var_0004[var_0009], var_0006, var_0001[var_0009], var_0005[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Art thou still interested?\"")
            var_000C = ask_yes_no()
            if not var_000C then
                if var_0002[var_0009] == 627 or var_0002[var_0009] == 595 then
                    add_dialogue("\"How many wouldst thou like?\"")
                    var_000B = utility_shop_1016(true, var_0008, var_0004[var_0009], 1, var_0003[var_0009], var_0002[var_0009])
                else
                    var_000B = utility_shop_1016(false, var_0008, var_0004[var_0009], 0, var_0003[var_0009], var_0002[var_0009])
                end
                if var_000B == 1 then
                    add_dialogue("\"Done!\"")
                elseif var_000B == 2 then
                    add_dialogue("\"Thou cannot possibly carry that much!\"")
                elseif var_000B == 3 then
                    add_dialogue("\"Thou dost not have enough gold for that!\"")
                end
                add_dialogue("\"Wouldst thou like something else?\"")
                var_0000 = ask_yes_no()
            end
        end
    end
    restore_answers()
end