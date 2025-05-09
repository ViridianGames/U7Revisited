--- Best guess: Manages a food shop interaction, allowing the purchase of various meats (e.g., dried meat, trout) with quantity and price validation.
function func_088C()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"dried meat", "meat on a spit", "flounder", "trout", "ham", "fowl", "beef", "mutton", "nothing"}
    var_0002 = 377
    var_0003 = {15, 14, 13, 12, 11, 10, 9, 8, -359}
    var_0004 = {2, 3, 7, 5, 20, 3, 20, 3, 0}
    var_0005 = ""
    var_0006 = 0
    var_0007 = {" for ten portions", " for one portion", " for one", " for one", " for one slice", " for one", " for one portion", " for one portion", ""}
    var_0008 = {10, 1, 1, 1, 1, 1, 1, 1, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_000A = unknown_091BH(var_0005, var_0001[var_0009], var_0006, var_0009, var_0007[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Does that sound like a fair price?\"")
            var_000C = unknown_090AH()
            if not var_000C then
                var_000A = "How many "
                if var_0008[var_0009] > 1 then
                    var_000A = var_000A .. "sets "
                end
                var_000A = var_000A .. "wouldst thou like?"
                add_dialogue("\"" .. var_000A .. "\"")
                var_000B = unknown_08F8H(true, var_0008[var_0009], var_0004[var_0009], 1, var_0003[var_0009], var_0002)
                if var_000B == 1 then
                    add_dialogue("\"Done!\"")
                elseif var_000B == 2 then
                    add_dialogue("\"Thou cannot possibly carry that much!\"")
                elseif var_000B == 3 then
                    add_dialogue("\"Thou dost not have enough gold for that!\"")
                end
                add_dialogue("\"Wouldst thou like something else?\"")
                var_0000 = unknown_090AH()
            end
        end
    end
    restore_answers()
end