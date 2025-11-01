--- Best guess: Manages a shop interaction, allowing the purchase of items (e.g., cloth, jar) with quantity and price validation, handling inventory and gold checks.
function utility_shop_0844()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    save_answers()
    var_0000 = true
    var_0001 = {"cloth", "jar", "bucket", "powder keg", "shovel", "oil flasks", "torch", "nothing"}
    var_0002 = {851, 824, 810, 704, 625, 782, 595, 0}
    var_0003 = {-359, 0, 0, -359, -359, -359, -359, -359}
    var_0004 = {3, 2, 4, 25, 12, 60, 4, 0}
    var_0005 = {"", "a ", "a ", "a ", "a ", "an ", "a ", ""}
    var_0006 = {" per bolt", "", "", "", "", " for a dozen", "", ""}
    var_0007 = {1, 1, 1, 1, 1, 12, 1, 0}
    add_dialogue("\"To purchase what item?\"")
    while var_0000 do
        var_0008 = utility_unknown_1036(var_0001)
        if var_0008 == 1 then
            add_dialogue("\"To be fine.\"")
            var_0000 = false
        else
            var_0009 = 1
            var_000A = 1
            var_000B = utility_shop_1052(var_0005[var_0008], var_0001[var_0008], var_0004[var_0008], var_0009, var_0006[var_0008])
            var_000C = 0
            add_dialogue("\"^" .. var_000B .. ". To be acceptable?\"")
            var_000D = ask_yes_no()
            if not var_000D then
                if var_0002[var_0008] == 595 or var_0002[var_0008] == 782 then
                    if var_0002[var_0008] == 782 then
                        add_dialogue("\"To want to buy how many sets of twelve?\"")
                    else
                        add_dialogue("\"To want to buy how many?\"")
                    end
                    var_000C = utility_shop_1016(true, var_0007[var_0008], var_0004[var_0008], 1, var_0003[var_0008], var_0002[var_0008])
                else
                    var_000C = utility_shop_1016(false, var_0007[var_0008], var_0004[var_0008], 0, var_0003[var_0008], var_0002[var_0008])
                end
                if var_000C == 1 then
                    add_dialogue("\"To be done!\"")
                elseif var_000C == 2 then
                    add_dialogue("\"To be unable to carry that much, human.\"")
                elseif var_000C == 3 then
                    add_dialogue("\"To have not the right amount of gold!\"")
                end
                add_dialogue("\"To buy something else?\"")
                var_0000 = ask_yes_no()
            end
        end
    end
    restore_answers()
end