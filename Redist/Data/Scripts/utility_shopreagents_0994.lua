--- Best guess: Manages a shop dialogue with a gargoyle vendor for purchasing magical reagents, handling item selection, pricing, and inventory checks, similar to func_08DC.
function utility_shopreagents_0994()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"sulfurous ash", "ginseng", "garlic", "blood moss", "nothing"}
    var_0002 = {842, 842, 842, 842, 0}
    var_0003 = {7, 5, 4, 1, 359}
    var_0004 = {3, 1, 1, 2, 0}
    var_0005 = ""
    var_0006 = 0
    var_0007 = {" per use", " per use", " per use", " per spell use", ""}
    var_0008 = 1
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"To be acceptable.\"")
            var_0000 = false
        else
            var_0010 = utility_shop_1052(var_0005, var_0004[var_0009], var_0006, var_0001[var_0009], var_0007[var_0009])
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. ". To agree to this price?")
            var_0012 = ask_yes_no()
            if not var_0012 then
                add_dialogue("\"To want to purchase how many?\"")
                var_0011 = utility_shop_1016(true, 1, 20, var_0004[var_0009], var_0008, var_0003[var_0009], var_0002[var_0009])
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