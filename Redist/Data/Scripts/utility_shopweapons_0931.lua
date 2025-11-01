--- Best guess: Manages a shop dialogue for purchasing ranged weapon ammunition (bolts, arrows), handling pricing and inventory checks.
function utility_shopweapons_0931()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"bolts", "arrows", "nothing"}
    var_0003 = {723, 722, 0}
    var_0004 = 359
    var_0005 = 20
    var_0006 = ""
    var_0007 = 1
    var_0008 = " for a dozen"
    var_0009 = 12
    add_dialogue("\"What dost thou wish to buy?\"")
    while var_0001 do
        var_0010 = utility_unknown_1036(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"All right.\"")
            var_0001 = false
        else
            var_0011 = utility_shop_1051(var_0006, var_0002[var_0010], var_0007, var_0005, var_0008)
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. " Is that agreeable?")
            var_0013 = ask_yes_no()
            if not var_0013 then
                add_dialogue("\"How many dozen wouldst thou like?\"")
                var_0012 = utility_shop_1016(true, 1, 20, var_0005, var_0009, var_0004, var_0003[var_0010])
            end
            if var_0012 == 1 then
                add_dialogue("\"Very good, " .. var_0000 .. ".\"")
            elseif var_0012 == 2 then
                add_dialogue("\"Thou cannot travel with that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou dost not have the gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like to buy something else?\"")
            var_0001 = ask_yes_no()
        end
    end
    restore_answers()
    restore_answers()
    return
end