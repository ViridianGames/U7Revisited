--- Best guess: Manages a food shop interaction, allowing the purchase of items (e.g., ham, trout) with quantity and price validation, handling inventory and gold checks.
function func_085D()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"ham", "cake", "Silverleaf", "trout", "mutton rations", "nothing"}
    var_0003 = {377, 377, 377, 377, 377, 0}
    var_0004 = {11, 5, 31, 12, 15, -359}
    var_0005 = {10, 2, 25, 2, 12, 0}
    var_0006 = ""
    var_0007 = {0, 0, 0, 0, 1, 0}
    var_0008 = {" for a slice", " per piece", " for one portion", " for one portion", " for ten portions", ""}
    var_0009 = {1, 1, 1, 1, 10, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_000A = unknown_090CH(var_0002)
        if var_000A == 1 then
            add_dialogue("\"Very well, " .. var_0000 .. ".\"")
            var_0001 = false
        elseif var_000A == 4 and not get_flag(299) then
            add_dialogue("\"Phearcy has said that we can no longer sell Silverleaf because we have no more and cannot again acquire the meal. I am truly sorry. Perhaps thou wouldst be interested in something else.\"")
        else
            var_000B = unknown_091BH(var_0006, var_0002[var_000A], var_0007[var_000A], var_000A, var_0008[var_000A])
            var_000C = 0
            add_dialogue("\"^" .. var_000B .. " Dost thou accept my price?\"")
            var_000D = unknown_090AH()
            if not var_000D then
                var_000B = "How many "
                if var_0004[var_000A] == 15 then
                    var_000B = var_000B .. "sets "
                end
                var_000B = var_000B .. "dost thou want?"
                add_dialogue("\"" .. var_000B .. "\"")
                var_000C = unknown_08F8H(true, var_0009[var_000A], var_0005[var_000A], 1, var_0004[var_000A], var_0003[var_000A])
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