--- Best guess: Manages a shop dialogue for purchasing food items, handling item selection, pricing, and Silverleaf scarcity based on a flag.
function func_08CB()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"ham", "cake", "Silverleaf", "trout", "mutton rations", "nothing"}
    var_0003 = {377, 377, 377, 377, 377, 0}
    var_0004 = {11, 5, 31, 12, 15, 359}
    var_0005 = {10, 2, 25, 2, 12, 0}
    var_0006 = {"", "", "", "", "", ""}
    var_0007 = {0, 0, 0, 0, 1, 0}
    var_0008 = {" for a slice", " per piece", " for one portion", " for one portion", " for ten servings", ""}
    var_0009 = {1, 1, 1, 1, 10, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Very well, " .. var_0000 .. ".\"")
            var_0001 = false
        elseif var_0010 == 4 and not get_flag(299) then
            add_dialogue("\"I am truly sorry, " .. var_0000 .. ", but I have not been able to get any of that for some time now. It seems the man who used to cut down the Silverleaf trees has stopped.\"")
        else
            var_0011 = unknown_091BH(var_0006[var_0010], var_0002[var_0010], var_0007[var_0010], var_0005[var_0010], var_0008[var_0010])
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. ". Art thou happy with the price?")
            var_0013 = ask_yes_no()
            if not var_0013 then
                add_dialogue("\"How many dost thou want?\"")
                var_0012 = unknown_08F8H(true, 1, 20, var_0005[var_0010], var_0009[var_0010], var_0004[var_0010], var_0003[var_0010])
            end
            if var_0012 == 1 then
                add_dialogue("\"Agreed.\"")
            elseif var_0012 == 2 then
                add_dialogue("\"Thou cannot carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou hast not the gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = ask_yes_no()
        end
    end
    restore_answers()
    return
end