--- Best guess: Manages a shop dialogue for purchasing alcoholic beverages (ale, wine), handling item selection, pricing, and inventory checks.
function func_08CC()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"ale", "wine", "nothing"}
    var_0003 = {616, 616, 0}
    var_0004 = {3, 5, 359}
    var_0005 = {3, 4, 0}
    var_0006 = {"", "", ""}
    var_0007 = {0, 0, 0}
    var_0008 = {" per bottle", " per bottle", ""}
    var_0009 = {1, 1, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Very well, " .. var_0000 .. ".\"")
            var_0001 = false
        else
            var_0011 = 0
            var_0012 = unknown_091BH(var_0006[var_0010], var_0002[var_0010], var_0007[var_0010], var_0005[var_0010], var_0008[var_0010])
            add_dialogue("^" .. var_0012 .. ". Is that price agreeable?")
            var_0013 = unknown_090AH()
            if not var_0013 then
                var_0011 = unknown_08F8H(true, 1, 0, var_0005[var_0010], var_0009[var_0010], var_0004[var_0010], var_0003[var_0010])
            end
            if var_0011 == 1 then
                add_dialogue("\"Agreed.\"")
            elseif var_0011 == 2 then
                add_dialogue("\"Thou cannot carry that much!\"")
            elseif var_0011 == 3 then
                add_dialogue("\"Thou hast not the gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restoreAnswers()
    return
end