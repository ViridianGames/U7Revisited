--- Best guess: Manages a clothing shop interaction, allowing the purchase of apparel (e.g., swamp boots, tunic) with price validation.
function func_088E()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"swamp boots", "pants", "dress", "tunic", "leather boots", "kidney belt", "shoes", "nothing"}
    var_0002 = {588, 738, 249, 249, 587, 584, 585, 0}
    var_0003 = {-359, 0, 1, 0, -359, -359, -359, -359}
    var_0004 = {50, 30, 30, 30, 40, 20, 20, 0}
    var_0005 = {"", "", "a ", "a ", "", "a ", "", ""}
    var_0006 = {1, 1, 0, 0, 1, 0, 1, 0}
    var_0007 = {" for one pair", " for one pair", "", "", " for one pair", "", " for one pair", ""}
    var_0008 = 1
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_000A = unknown_091BH(var_0005[var_0009], var_0001[var_0009], var_0004[var_0009], var_0006[var_0009], var_0007[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Is that acceptable?\"")
            var_000C = unknown_090AH()
            if not var_000C then
                var_000B = unknown_08F8H(true, var_0008, var_0004[var_0009], 0, var_0003[var_0009], var_0002[var_0009])
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