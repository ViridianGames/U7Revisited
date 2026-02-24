--- Best guess: Manages purchase of weapons (e.g., bolts, sword).
function utility_shopweapons_0882()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E
    debug_print("Started 0872")
    var_0000 = true
    var_0001 = {"\"What wouldst thou like?\"", "bolts - 15 gold for a dozen", "arrows - 10 gold for a dozen", "bow - 30 gold", "sling - 10 gold", "club - 15 gold", "2-handed sword - 80 gold", "2-handed hammer - 60 gold", "sword - 50 gold", "mace - 15 gold", "dagger - 10 gold", "nothing"}
    var_0002 = {723, 722, 597, 474, 590, 602, 600, 599, 659, 594, 0}
    var_0003 = 359
    var_0004 = {15, 10, 30, 10, 15, 80, 60, 50, 15, 10, 0}
    var_0005 = {"", "", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", ""}
    var_0006 = {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    var_0007 = {" for a dozen", " for a dozen", "", "", "", "", "", "", "", "", ""}
    var_0008 = {12, 12, 1, 1, 1, 1, 1, 1, 1, 1, 0}
    amount = 0
    while var_0000 do
        var_0009 = get_purchase_option(var_0001)
        if var_0009 == 0 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_0009 = 11 - var_0009
            -- Bolts and arrows can be bought in multiple sets
            if var_0002[var_0009] == 722 or var_0002[var_0009] == 723 then
                amount = ask_number("\"How many sets wouldst thou like?\"", 0, 20, 1)
                amount = amount * 12
            else
                amount = 1
            end
            var_000B = purchase_object(var_0002[var_0009], 0, var_0004[var_0009], amount)
            if var_000B == 0 then
                add_dialogue("\"Fine.\"")
            elseif var_000B == 1 then
                add_dialogue("\"Very good. At last we are getting somewhere!\"")
            elseif var_000B == 2 then
                add_dialogue("\"Thou hast thine hands full, idiot!\"")
            elseif var_000B == 3 then
                add_dialogue("\"Thou hast a lot of gall attempting to buy something from my shop without enough gold in thy possession!\"")
            end
            var_0000 = ask_yes_no("\"Anything else for thee today?\"")
        end
    end
end