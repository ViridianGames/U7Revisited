--- Best guess: Manages a food shop interaction, allowing the purchase of items (e.g., flounder, bread) with quantity and price validation.
function func_094D()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    save_answers()
    var_0000 = true
    var_0001 = {"flounder", "bread", "mutton rations", "nothing"}
    var_0002 = {4, 4, 20, 0}
    var_0003 = 377
    var_0004 = {13, 0, 15, -359}
    var_0005 = ""
    var_0006 = {0, 0, 1, 0}
    var_0007 = {" for one portion", " for one loaf", " for 10 portions", ""}
    var_0008 = {1, 1, 10, 0}
    add_dialogue("\"What would ye like?\"")
    while var_0000 do
        var_0009 = _SelectIndex(var_0001)
        if var_0009 == 1 then
            add_dialogue("\"If ye say so. I know that blasted Britannian Tax Council or what have ye has made the cost o' things too high! Maybe next time!\"")
            var_0000 = false
        else
            var_000A = _FormatPrice(var_0005, var_0002[var_0009], var_0006[var_0009], var_0001[var_0009], var_0007[var_0009])
            var_000B = 0
            add_dialogue("\"^" .. var_000A .. " Is that acceptable?\"")
            var_000C = _SelectOption()
            if not var_000C then
                add_dialogue("\"How much do ye want?\"")
                var_000B = unknown_08F8H(true, 1, 20, var_0002[var_0009], var_0008[var_0009], var_0004[var_0009], var_0003)
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