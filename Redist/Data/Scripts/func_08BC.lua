--- Best guess: Manages a shop dialogue for purchasing reagents or potions, handling item selection, pricing, and inventory checks based on the input parameter.
function func_08BC(eventid)
    start_conversation()
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015

    save_answers()
    var_0001 = true
    if eventid == "Reagents" then
        var_0002 = {"Black Pearl", "Nightshade", "Mandrake Root", "Ginseng", "Garlic", "Nothing"}
        var_0003 = {842, 842, 842, 842, 842, 0}
        var_0004 = {0, 2, 3, 5, 4, 359}
        var_0005 = {8, 6, 7, 2, 1, 0}
        var_0006 = ""
        var_0007 = {" each", " for one button", " each", " for one portion", " for one clove", ""}
    else
        var_0002 = {"black potion", "orange potion", "nothing"}
        var_0003 = {340, 340, 0}
        var_0004 = {7, 4, 359}
        var_0005 = {90, 15, 0}
        var_0008 = {"a ", "a ", ""}
        var_0007 = {" for one vial", " for one vial", ""}
    end
    var_0009 = 0
    var_0010 = 1
    var_0011 = -153
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_0012 = unknown_090CH(var_0002)
        if var_0012 == 1 then
            add_dialogue("\"Fine.\"")
            var_0001 = false
        else
            var_0013 = unknown_091BH(var_0006 or var_0008[var_0012], var_0002[var_0012], var_0009, var_0005[var_0012], var_0007[var_0012])
            var_0014 = 0
            add_dialogue("\"" .. var_0013 .. " Dost thou like the price?\"")
            var_0015 = unknown_090AH()
            if not var_0015 then
                if eventid == "Reagents" then
                    add_dialogue("\"How many dost thou want?\"")
                    var_0014 = unknown_08F8H(false, 1, 20, var_0005[var_0012], var_0010, var_0004[var_0012], var_0003[var_0012])
                else
                    var_0014 = unknown_08F8H(false, 1, 0, var_0005[var_0012], var_0010, var_0004[var_0012], var_0003[var_0012])
                end
            end
            if var_0014 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0014 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0014 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    return
end