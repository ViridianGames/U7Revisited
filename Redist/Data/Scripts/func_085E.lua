--- Best guess: Manages a tavern interaction, allowing the purchase of ale or wine with price validation, handling inventory and gold checks.
function func_085E()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"ale", "wine", "nothing"}
    var_0003 = {616, 616, 0}
    var_0004 = {3, 5, -359}
    var_0005 = {3, 4, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = " per bottle"
    var_0009 = 1
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_000A = unknown_090CH(var_0002)
        if var_000A == 1 then
            add_dialogue("\"Very well, " .. var_0000 .. ".\"")
            var_0001 = false
        else
            var_000B = unknown_091BH(var_0006, var_0002[var_000A], var_0007, var_000A, var_0008)
            var_000C = 0
            add_dialogue("\"^" .. var_000B .. " Dost thou accept my price?\"")
            var_000D = unknown_090AH()
            if not var_000D then
                var_000C = unknown_08F8H(true, var_0009, var_0005[var_000A], 0, var_0004[var_000A], var_0003[var_000A])
                if var_000C == 1 then
                    add_dialogue("\"Agreed.\"")
                elseif var_000C == 2 then
                    add_dialogue("\"Thou cannot carry that much!\"")
                elseif var_000C == 3 then
                    add_dialogue("\"Thou hast not the gold for that!\"")
                end
                add_dialogue("\"Wouldst thou like something else?\"")
                var_0001 = unknown_090AH()
            end
        end
    end
    restore_answers()
end