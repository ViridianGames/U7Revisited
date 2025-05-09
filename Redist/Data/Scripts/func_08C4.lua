--- Best guess: Manages a shop dialogue for purchasing magical reagents, handling item selection, pricing, and inventory checks with a casual tone.
function func_08C4()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    save_answers()
    var_0000 = true
    var_0001 = {"Nightshade", "Mandrake Root", "Spider Silk", "Blood Moss", "Garlic", "nothing"}
    var_0002 = {842, 842, 842, 842, 842, 0}
    var_0003 = {2, 3, 6, 1, 4, 359}
    var_0004 = {5, 5, 3, 3, 2, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0000 do
        var_0005 = unknown_090CH(var_0001)
        if var_0005 == 1 then
            add_dialogue("\"Fine.\"")
            var_0000 = false
        else
            var_0006 = ""
            var_0007 = 0
            var_0008 = ""
            var_0009 = 1
            var_0010 = unknown_091BH(var_0008, var_0001[var_0005], var_0007, var_0004[var_0005], var_0006)
            var_0011 = 0
            add_dialogue("^" .. var_0010 .. " Okey-dokey?")
            var_0012 = unknown_090AH()
            if not var_0012 then
                add_dialogue("\"How many wouldst thou like?\"")
                var_0011 = unknown_08F8H(true, 1, 20, var_0004[var_0005], var_0009, var_0003[var_0005], var_0002[var_0005])
            end
            if var_0011 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0011 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0011 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0000 = unknown_090AH()
        end
    end
    restore_answers()
    return
end