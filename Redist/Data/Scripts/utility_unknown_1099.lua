--- Best guess: Manages a haggling interaction for an item's price, allowing the player to counter-offer and returning the final agreed price.
function utility_unknown_1099(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    var_0000 = 0
    var_0001 = P1
    var_0002 = P1
    var_0003 = true
    var_0004 = false
    var_0005 = 0
    while var_0003 do
        if not var_0004 then
            add_dialogue("\"To be my final offer -- " .. var_0001 .. ".\"")
        else
            var_0006 = get_player_name(P0)
            add_dialogue("\"To want " .. var_0001 .. " gold.\"")
        end
        var_0007 = var_0001 * 3
        var_0008 = var_0007 / 2
        var_0009 = var_0001 / 2
        var_000A = var_0001 / 4
        var_000B = {var_000A, var_0009, var_0001, var_0008}
        if var_0004 then
            add_dialogue("\"To accept?\"")
            var_0005 = _SelectOption()
            if var_0005 then
                add_dialogue("\"To have a deal.\"")
                return var_0001
            else
                add_dialogue("\"To wonder why you bothered me.\"")
                return 0
            end
        end
        var_0002 = var_0001
        add_dialogue("\"To have another offer?\"")
        var_0001 = ask_number(0, 1, var_0008, 0)
        if var_0001 == 0 then
            add_dialogue("\"To notice you are obviously not interested.\"")
            return 0
        elseif var_0001 >= var_0001 then
            add_dialogue("\"To accept your offer.\"")
            return var_0001
        elseif var_0001 < var_000B[4] then
            add_dialogue("\"To be happy,\" he says. \"To have wanted to keep it anyway! To tell you to leave.\"")
            abort()
            return 0
        end
        var_0005 = get_random(100)
        if var_0002 == 0 then
            var_0002 = var_000B[3]
        end
        if var_0001 >= var_000B[4] then
            if var_0005 >= 90 then
                var_0004 = true
                var_000D = utility_unknown_1074((var_0001 - var_0002) * 2)
                var_000D = get_random(var_000D)
                if var_0001 - var_000D <= var_0001 then
                    var_0001 = var_0001 + 1
                else
                    var_0001 = var_0001 - var_000D
                end
            elseif var_0005 >= 30 then
                var_000D = utility_unknown_1074((var_0001 - var_0002) * 2)
                var_000D = get_random(var_000D)
                if var_0001 - var_000D <= var_0001 then
                    var_0001 = var_0001 + 1
                else
                    var_0001 = var_0001 - var_000D
                end
            else
                add_dialogue("\"To be agreed!\"")
                return var_0001
            end
        elseif var_0001 >= var_000B[3] then
            if var_0005 >= 40 then
                var_0004 = true
                var_000D = utility_unknown_1074((var_0001 - var_0002) * 2)
                var_000D = get_random(var_000D)
                if var_0001 - var_000D <= var_0001 then
                    var_0001 = var_0001 + 1
                else
                    var_0001 = var_0001 - var_000D
                end
            else
                add_dialogue("\"To be foolish to accept so little!\"")
                return 0
            end
        elseif var_0005 >= 5 then
            add_dialogue("\"To charge more next time. To have sold to you too cheaply!\"")
        end
        return var_0001
    end
end