--- Best guess: Manages a tavern interaction, allowing the purchase of drinks (ale, wine, mead) with price and inventory validation.
function utility_unknown_1102()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"ale", "wine", "mead", "nothing"}
    var_0002 = {1, 1, 5, 0}
    var_0003 = 616
    var_0004 = {3, 5, 0, -359}
    var_0005 = ""
    var_0006 = 0
    var_0007 = " per bottle"
    var_0008 = 1
    add_dialogue("\"What would ye like?\"")
    while var_0000 do
        var_0009 = _SelectIndex(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"If ye say so. I know that blasted Britannian Tax Council or what have ye has made the cost o' things too high! Maybe next time!\"")
            var_0000 = false
        else
            var_000A = _FormatPrice(var_0005, var_0002[var_0009], var_0006, var_0001[var_0009], var_0007)
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. ". Do ye find the price agreeable?\"")
            var_000C = _SelectOption()
            if not var_000C then
                var_000B = utility_shop_1016(true, 1, 0, var_0002[var_0009], var_0008, var_0004[var_0009], var_0003)
                if var_000B == 1 then
                    add_dialogue("\"Done!\"")
                elseif var_000B == 2 then
                    add_dialogue("\"Ye got ta lighten yer load first!\"")
                elseif var_000B == 3 then
                    add_dialogue("\"Ye've not got the gold. I kinna do business like that!\"")
                end
                add_dialogue("\"Anything else ye want?\"")
                var_0000 = _SelectOption()
            end
        end
    end
    restore_answers()
end