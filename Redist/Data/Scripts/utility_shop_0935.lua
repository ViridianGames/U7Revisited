--- Best guess: Manages a shop dialogue for purchasing produce (e.g., grapes, eggs), handling item selection, pricing, and inventory checks with quantity prompts for bulk items.
function utility_shop_0935()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"grapes", "pumpkin", "carrot", "banana", "apple", "eggs", "nothing"}
    var_0002 = {377, 377, 377, 377, 377, 377, 0}
    var_0003 = {19, 21, 18, 17, 16, 24, 359}
    var_0004 = {3, 4, 3, 3, 3, 12, 0}
    var_0005 = {"", "a ", "a ", "a ", "an ", "", ""}
    var_0006 = {1, 1, 1, 1, 1, 12, 0}
    var_0007 = {" for a bunch", "", "", "", "", " for one dozen", ""}
    var_0008 = {1, 1, 1, 1, 1, 12, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_0010 = utility_shop_1051(var_0005[var_0009], var_0001[var_0009], var_0006[var_0009], var_0004[var_0009], var_0007[var_0009])
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. " Wilt thou pay my price?")
            var_0012 = ask_yes_no()
            if not var_0012 then
                local quantity_text = "How many "
                if var_0008[var_0009] > 1 then
                    quantity_text = quantity_text .. "dozen "
                end
                quantity_text = quantity_text .. "wouldst thou like?"
                add_dialogue("\"" .. quantity_text .. "\"")
                var_0011 = utility_shop_1016(true, 1, 20, var_0004[var_0009], var_0008[var_0009], var_0003[var_0009], var_0002[var_0009])
            end
            if var_0011 == 1 then
                add_dialogue("\"Thou wilt indeed be pleased with thy purchase. We have only the finest produce.\"")
            elseif var_0011 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0011 == 3 then
                add_dialogue("\"Thou dost not have enough coin to pay for that!\"")
            end
            add_dialogue("\"Wouldst thou like to purchase something else?\"")
            var_0000 = ask_yes_no()
        end
    end
    restore_answers()
    return
end