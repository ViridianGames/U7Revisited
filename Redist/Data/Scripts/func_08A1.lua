--- Best guess: Manages a shop dialogue for purchasing adventuring gear, handling item selection, pricing, and inventory checks with quantity prompts.
function func_08A1()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"cannon balls", "jug", "powder keg", "lockpick", "backpack", "oil flasks", "torch", "nothing"}
    var_0003 = {703, 6, 704, 627, 801, 782, 595, 0}
    var_0004 = {10, 3, 30, 10, 13, 60, 4, 0}
    var_0005 = {"", "a ", "a ", "a ", "a ", "", "a ", ""}
    var_0006 = {1, 0, 0, 0, 0, 1, 0, 0}
    var_0007 = {" each", "", "", "", "", " for a dozen", "", ""}
    var_0008 = 359
    var_0009 = 1
    add_dialogue("\"What dost thou want to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Fine, " .. var_0000 .. ".\"")
            var_0001 = false
        else
            var_0011 = unknown_091BH(var_0005[var_0010], var_0002[var_0010], var_0006[var_0010], var_0004[var_0010], var_0007[var_0010])
            var_0012 = 0
            if var_0003[var_0010] == 782 or var_0003[var_0010] == 595 or var_0003[var_0010] == 627 then
                add_dialogue("^" .. var_0011 .. " Dost thou agree?")
                var_0013 = unknown_090AH()
                if not var_0013 then
                    if var_0003[var_0010] == 782 then
                        add_dialogue("\"How many sets of twelve wouldst thou like?\"")
                    else
                        add_dialogue("\"How many wouldst thou like?\"")
                    end
                    var_0012 = unknown_08F8H(true, 1, 20, var_0004[var_0010], var_0009, var_0008, var_0003[var_0010])
                end
            else
                add_dialogue("^" .. var_0011 .. ". Is that acceptable?")
                var_0014 = unknown_090AH()
                if not var_0014 then
                    var_0012 = unknown_08F8H(true, 1, 0, var_0004[var_0010], var_0009, var_0008, var_0003[var_0010])
                end
            end
            if var_0012 == 1 then
                add_dialogue("\"Very good, " .. var_0000 .. ".\"")
            elseif var_0012 == 2 then
                add_dialogue("\"But, " .. var_0000 .. ", thou cannot possibly carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"I am sorry, but thou hast not enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou care to purchase something else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    return
end