--- Best guess: Manages a weapons shop interaction, allowing the purchase of weapons (e.g., boomerang, throwing axe) with price validation.
function func_089C()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"boomerang", "two-handed axe", "throwing axe", "nothing"}
    var_0002 = {605, 601, 593, 0}
    var_0003 = -359
    var_0004 = {12, 50, 18, 0}
    var_0005 = "a "
    var_0006 = 1
    var_0007 = ""
    var_0008 = 1
    add_dialogue("\"To purchase what item?\"")
    while var_0000 do
        var_0009 = unknown_090CH(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"To be accepted.\"")
            var_0000 = false
        else
            var_000A = unknown_091CH(var_0007, var_0004[var_0009], var_0006, var_0001[var_0009], var_0005)
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " To be agreeable?\"")
            var_000C = unknown_090AH()
            if not var_000C then
                var_000B = unknown_08F8H(false, var_0008, var_0004[var_0009], 0, var_0003, var_0002[var_0009])
                if var_000B == 1 then
                    add_dialogue("\"To be agreed.\"")
                elseif var_000B == 2 then
                    add_dialogue("\"To be without the ability to carry that much!\"")
                elseif var_000B == 3 then
                    add_dialogue("\"To have less than enough gold for that.\"")
                end
                add_dialogue("\"To want something else?\"")
                var_0000 = unknown_090AH()
            end
        end
    end
    restore_answers()
end