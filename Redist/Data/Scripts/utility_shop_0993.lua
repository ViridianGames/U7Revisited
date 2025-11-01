--- Best guess: Manages a shop dialogue with a gargoyle vendor for purchasing potions and jewelry, handling item selection, pricing, and inventory checks.
function utility_shop_0993()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"white potion", "black potion", "gold clawring", "gold earring", "gold chain", "gold horncaps", "nothing"}
    var_0002 = {340, 340, 937, 937, 937, 937, 0}
    var_0003 = {6, 7, 6, 5, 4, 2, 359}
    var_0004 = {110, 60, 10, 5, 20, 30, 0}
    var_0005 = {"a ", "a ", "a ", "a ", "a ", "", ""}
    var_0006 = {0, 0, 0, 0, 0, 1, 0}
    var_0007 = {"", "", "", "", "", " per pair", ""}
    var_0008 = 1
    add_dialogue("\"To want to buy what item?\"")
    while var_0000 do
        var_0009 =-pod utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"To be acceptable.\"")
            var_0000 = false
        else
            var_0010 = utility_shop_1052(var_0005[var_0009], var_0004[var_0009], var_0006[var_0009], var_0001[var_0009], var_0007[var_0009])
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. ". To be an acceptable price?")
            var_0012 = ask_yes_no()
            if not var_0012 then
                var_0011 = utility_shop_1016(false, 1, 0, var_0004[var_0009], var_0008, var_0003[var_0009], var_0002[var_0009])
            end
            if var_0011 == 1 then
                add_dialogue("\"To be agreed!\"")
            elseif var_0011 == 2 then
                add_dialogue("\"To be unable to carry that much!\" He shakes his head.")
            elseif var_0011 == 3 then
                add_dialogue("\"To have not enough gold for that!\"")
            end
            add_dialogue("\"To desire another item?\"")
            var_0000 = ask_yes_no()
        end
    end
    restore_answers()
    return
end