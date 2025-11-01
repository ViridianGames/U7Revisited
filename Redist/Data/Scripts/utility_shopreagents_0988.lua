--- Best guess: Manages a shop dialogue for purchasing magical reagents, handling item selection, pricing, and inventory checks, similar to func_08C6.
function utility_shopreagents_0988()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"Black Pearl", "Mandrake Root", "Sulfurous Ash", "Blood Moss", "Ginseng", "nothing"}
    var_0002 = {842, 842, 842, 842, 842, 0}
    var_0003 = {0, 3, 7, 1, 5, 359}
    var_0004 = {5, 5, 4, 3, 2, 0}
    var_0005 = ""
    var_0006 = 0
    var_0007 = ""
    var_0008 = 1
    add_dialogue("\"What reagent wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_0010 = utility_shop_1051(var_0007, var_0001[var_0009], var_0006, var_0004[var_0009], var_0005)
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. " Art thou willing to pay that much?")
            var_0012 = ask_yes_no()
            if not var_0012 then
                add_dialogue("\"How many wouldst thou like?\"")
                var_0011 = utility_shop_1016(false, 1, 20, var_0004[var_0009], var_0008, var_0003[var_0009], var_0002[var_0009])
            end
            if var_0011 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0011 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0011 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0000 = ask_yes_no()
        end
    end
    restore_answers()
    return
end