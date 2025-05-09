--- Best guess: Manages a shop dialogue for purchasing tavern items (e.g., ale, mutton), handling item selection, pricing, and Silverleaf scarcity.
function func_08B9()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"ale", "wine", "Silverleaf", "flounder", "bread", "mutton", "nothing"}
    var_0003 = {616, 616, 377, 377, 377, 377, 0}
    var_0004 = {3, 5, 31, 13, 1, 8, 359}
    var_0005 = {5, 5, 50, 5, 5, 6, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" per bottle", " per bottle", " for one portion", " for one portion", " for one loaf", " for one portion", ""}
    var_0009 = 1
    add_dialogue("\"What suits thy fancy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Mmmm. Thou wilt love it.\"")
            var_0001 = false
        elseif var_0010 == 5 then
            if not get_flag(299) then
                add_dialogue("\"I have no more left, " .. var_0000 .. ". Silverleaf trees are no longer being cut down and my supply has diminished.\"")
            end
        else
            var_0011 = unknown_091BH(var_0006, var_0002[var_0010], var_0007, var_0005[var_0010], var_0008[var_0010])
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. " Too rich for thy blood?")
            var_0013 = unknown_090AH()
            if not var_0013 then
                if var_0003[var_0010] == 377 then
                    add_dialogue("\"How many wouldst thou like?\"")
                    var_0012 = unknown_08F8H(true, 1, 20, var_0005[var_0010], var_0009, var_0004[var_0010], var_0003[var_0010])
                else
                    var_0012 = unknown_08F8H(true, 1, 0, var_0005[var_0010], var_0009, var_0004[var_0010], var_0003[var_0010])
                end
            end
            if var_0012 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0012 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    return
end