--- Best guess: Manages a shop interaction for purchasing magical reagents (e.g., black pearl, mandrake root), with haggling and inventory checks.
function utility_shopreagents_1098()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    save_answers()
    var_0000 = true
    var_0001 = {"black pearl", "mandrake root", "sulfurous ash", "spider silk", "blood moss", "nothing"}
    var_0002 = {842, 842, 842, 842, 842, 0}
    var_0003 = {0, 3, 7, 6, 1, -359}
    var_0004 = {8, 8, 6, 5, 4, 0}
    var_0005 = {34, 32, 25, 20, 16, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = ""
    var_0009 = 1
    add_dialogue("\"To want what item?\"")
    while var_0000 do
        var_000A = _SelectIndex(var_0001)
        if var_000A == 1 then
            if get_flag(3) then
                add_dialogue("\"To understand.\"")
            else
                add_dialogue("\"To be good. To want to sell nothing to you.\"")
            end
            var_0000 = false
        else
            if get_flag(3) then
                var_000B = var_0004[var_000A]
                var_000C = _FormatPrice(var_0006, var_000B, var_0007, var_0001[var_000A], var_0008)
            else
                var_000B = utility_unknown_1099(-216, var_000B)
                var_000C = _FormatPrice(var_0006, var_000B, var_0007, var_0001[var_000A], var_0008)
                if var_000B == 0 then
                    goto continue
                end
            end
            var_000D = 0
            add_dialogue("\"" .. var_000C .. " To agree to the cost?\"")
            var_000E = select_option()
            if not var_000E then
                add_dialogue("\"To want how many?\"")
                var_000D = utility_shop_1016(true, 1, 20, var_000B, var_0009, var_0003[var_000A], var_0002[var_000A])
                if var_000D == 1 then
                    add_dialogue("\"To be agreed!\"")
                elseif var_000D == 2 then
                    add_dialogue("\"To be unable to carry that much, human!\"")
                elseif var_000D == 3 then
                    add_dialogue("\"To have not enough gold for that!\"")
                end
                add_dialogue("\"To want something else?\"")
                var_0000 = select_option()
            end
        end
        ::continue::
    end
    restore_answers()
end