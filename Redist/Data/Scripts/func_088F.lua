--- Best guess: Manages a tavern interaction, allowing the purchase of ale or wine with price validation, handling inventory and gold checks.
function func_088F()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"ale", "wine", "nothing"}
    var_0002 = {616, 616, 0}
    var_0003 = {3, 5, -359}
    var_0004 = {5, 5, 0}
    var_0005 = ""
    var_0006 = 0
    var_0007 = {" for a tankard", " for a bottle", ""}
    var_0008 = 1
    add_dialogue("\"What wouldst thou like to whet thy palate?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine choice.\"")
            var_0000 = false
        else
            var_000A = unknown_091BH(var_0005, var_0001[var_0009], var_0006, var_0009, var_0007[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Dost thou think it worth the cost?\"")
            var_000C = unknown_090AH()
            if not var_000C then
                var_000B = unknown_08F8H(true, var_0008, var_0004[var_0009], 0, var_0003[var_0009], var_0002[var_0009])
                if var_000B == 1 then
                    add_dialogue("\"Thou art correct!\"")
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