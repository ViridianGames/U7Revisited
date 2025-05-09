--- Best guess: Manages a shop dialogue for purchasing food and drink items, handling item selection, pricing, and inventory checks with quantity prompts.
function func_08CD()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"wine", "ale", "bread", "cheese", "grapes", "mead", "jerky", "nothing"}
    var_0002 = {616, 616, 377, 377, 377, 616, 377, 0}
    var_0003 = {5, 3, 0, 27, 19, 0, 15, 359}
    var_0004 = {2, 1, 2, 4, 1, 4, 12, 0}
    var_0005 = ""
    var_0006 = {0, 0, 0, 1, 0, 0, 0}
    var_0007 = {" for a bottle", " for a bottle", " for a loaf", " per wedge", " for one bunch", " for a bottle", " for 10 pieces", ""}
    var_0008 = {1, 1, 1, 1, 1, 1, 10, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"All right.\"")
            var_0000 = false
        else
            var_0010 = unknown_091BH(var_0005, var_0001[var_0009], var_0006[var_0009], var_0004[var_0009], var_0007[var_0009])
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. " Canst thou afford my price?")
            var_0012 = unknown_090AH()
            if not var_0012 then
                if var_0002[var_0009] == 616 then
                    var_0011 = unknown_08F8H(true, 1, 0, var_0004[var_0009], var_0008[var_0009], var_0003[var_0009], var_0002[var_0009])
                else
                    local prompt = "How many "
                    if var_0008[var_0009] > 1 then
                        prompt = prompt .. "sets "
                    end
                    prompt = prompt .. "wouldst thou like?"
                    add_dialogue("^" .. prompt)
                    var_0011 = unknown_08F8H(true, 1, 20, var_0004[var_0009], var_0008[var_0009], var_0003[var_0009], var_0002[var_0009])
                end
            end
            if var_0011 == 1 then
                add_dialogue("\"Excellent.\"")
            elseif var_0011 == 2 then
                add_dialogue("\"Thou cannot carry that much of a load.\"")
            elseif var_0011 == 3 then
                add_dialogue("\"Thou dost not have the gold for that!\"")
            end
            add_dialogue("\"Is there something else thou mayest wish to buy?\"")
            var_0000 = unknown_090AH()
        end
    end
    restore_answers()
    return
end