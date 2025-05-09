--- Best guess: Manages a clothing shop interaction, allowing the purchase of apparel (e.g., hood, tunic) with price validation, handling inventory and gold checks.
function func_085C()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"hood", "dress", "pants", "tunic", "heavy cloak", "nothing"}
    var_0002 = {444, 249, 738, 249, 285, 0}
    var_0003 = {10, 45, 30, 30, 50, 0}
    var_0004 = {"a ", "a ", "", "a ", "a ", ""}
    var_0005 = {0, 0, 1, 0, 0, 0}
    var_0006 = {"", "", " per pair", "", "", ""}
    var_0007 = {1, 1, 1, 0, 1, -359}
    var_0008 = 1
    add_dialogue("\"What article wouldst thou like to buy?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"Fine!\"")
            var_0000 = false
        else
            var_000A = unknown_091BH(var_0004[var_0009], var_0001[var_0009], var_0005[var_0009], var_0009, var_0006[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Art thou willing to pay my price?\"")
            var_000C = unknown_090AH()
            if not var_000C then
                var_000B = unknown_08F8H(false, var_0008, var_0003[var_0009], 0, var_0007[var_0009], var_0002[var_0009])
                if var_000B == 1 then
                    add_dialogue("\"Excellent choice!\"")
                elseif var_000B == 2 then
                    add_dialogue("\"Thou must put away one of thine other items before thou canst take this fine piece of clothing.\"")
                elseif var_000B == 3 then
                    add_dialogue("\"Thou dost not have enough gold for my fine apparel. Perhaps in the near future.\"")
                end
                add_dialogue("\"Is there something else thou wouldst like to see?\"")
                var_0000 = unknown_090AH()
            end
        end
    end
    restore_answers()
end