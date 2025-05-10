--- Best guess: Manages a shop dialogue for purchasing ranged weapons (bows, crossbows), handling pricing and inventory checks.
function func_08A4()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"magic bow", "triple crossbow", "crossbow", "bow", "nothing"}
    var_0003 = {606, 647, 598, 597, 0}
    var_0004 = 359
    var_0005 = {400, 350, 110, 35, 0}
    var_0006 = "a "
    var_0007 = 0
    var_0008 = ""
    var_0009 = 1
    add_dialogue("\"What dost thou wish to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"All right.\"")
            var_0001 = false
        else
            var_0011 = unknown_091BH(var_0006, var_0002[var_0010], var_0007, var_0005[var_0010], var_0008)
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. " Is that agreeable?")
            var_0013 = unknown_090AH()
            if not var_0013 then
                var_0012 = unknown_08F8H(false, 1, 0, var_0005[var_0010], var_0009, var_0004, var_0003[var_0010])
            end
            if var_0012 == 1 then
                add_dialogue("\"Very good, " .. var_0000 .. ".\"")
            elseif var_0012 == 2 then
                add_dialogue("\"Thou cannot travel with that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou dost not have the gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like to buy something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    restore_answers()
    return
end