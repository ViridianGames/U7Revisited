--- Best guess: Manages a shop dialogue for purchasing potions (e.g., healing, invisibility), handling item selection, pricing, and inventory checks with quantity prompts.
function utility_shop_0936()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"awakening", "healing", "invisibility", "protection", "sleep", "illumination", "curative", "poison", "nothing"}
    var_0002 = 340
    var_0003 = {4, 1, 7, 5, 0, 6, 2, 3, 359}
    var_0004 = {30, 150, 100, 150, 15, 50, 150, 15, 0}
    var_0005 = {"an ", "a ", "an ", "a ", "a ", "an ", "a ", "a ", ""}
    var_0006 = 0
    var_0007 = " for one potion"
    var_0008 = 1
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_0010 = utility_shop_1051(var_0005[var_0009], var_0001[var_0009], var_0006, var_0004[var_0009], var_0007)
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. " Dost thou still wish to trade?")
            var_0012 = ask_yes_no()
            if not var_0012 then
                add_dialogue("\"How many wouldst thou like?\"")
                var_0011 = utility_shop_1016(false, 1, 20, var_0004[var_0009], var_0008, var_0003[var_0009], var_0002)
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