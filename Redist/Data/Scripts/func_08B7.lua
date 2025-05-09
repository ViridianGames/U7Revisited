--- Best guess: Manages a shop dialogue for purchasing food and drink items, similar to func_08A0, with handling for Silverleaf scarcity.
function func_08B7()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"wine", "ale", "cake", "bread", "Silverleaf", "ham", "trout", "mead", "beef", "mutton", "nothing"}
    var_0003 = {616, 616, 377, 377, 377, 377, 377, 616, 377, 377, 0}
    var_0004 = {5, 3, 4, 0, 31, 11, 12, 0, 9, 8, 359}
    var_0005 = {5, 5, 3, 4, 50, 20, 5, 15, 20, 6, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" for a bottle", " for a bottle", " for one piece", " for a loaf", " for one portion", " for one slice", " for one portion", " for a bottle", " for a rack", " for one portion", ""}
    var_0009 = 1
    var_0010 = -37
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_0011 = unknown_090CH(var_0002)
        if var_0011 == 1 then
            add_dialogue("\"Fine.\"")
            var_0001 = false
        elseif var_0011 == 7 then
            if not get_flag(299) then
                add_dialogue("\"Oh, I am so terribly sorry, " .. var_0000 .. ", but there is no more. The logger in Yew refuses to chop down any more Silverleaf trees. I, personally, thinks it is a dreadful decision.\"")
            end
        else
            var_0012 = unknown_091BH(var_0006, var_0002[var_0011], var_0007, var_0005[var_0011], var_0008[var_0011])
            var_0013 = 0
            add_dialogue("^" .. var_0012 .. " Dost thou still want it?")
            var_0014 = unknown_090AH()
            if not var_0014 then
                if var_0003[var_0011] == 377 then
                    add_dialogue("\"How many wouldst thou like?\"")
                    var_0013 = unknown_08F8H(true, 1, 20, var_0005[var_0011], var_0009, var_0004[var_0011], var_0003[var_0011])
                else
                    var_0013 = unknown_08F8H(true, 1, 0, var_0005[var_0011], var_0009, var_0004[var_0011], var_0003[var_0011])
                end
            end
            if var_0013 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0013 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0013 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    return
end