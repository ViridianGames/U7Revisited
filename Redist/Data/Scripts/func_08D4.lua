--- Best guess: Manages a shop dialogue for purchasing armor pieces, handling item selection, pricing, and inventory checks.
function func_08D4()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"gorget", "plate leggings", "great helm", "spiked shield", "curved heater", "buckler", "gauntlets", "greaves", "nothing"}
    var_0003 = {586, 576, 541, 578, 545, 543, 580, 353, 0}
    var_0004 = {30, 175, 160, 150, 22, 35, 18, 18, 40, 0}
    var_0005 = {"a ", "", "a ", "a ", "a ", "a ", "", "", ""}
    var_0006 = {0, 1, 0, 0, 0, 0, 1, 1, 0}
    var_0007 = {"", " per pair", "", "", "", "", " per pair", " per pair", ""}
    var_0008 = 359
    var_0009 = 1
    add_dialogue("\"What form of protection wouldst thou like to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Very well.\"")
            var_0011 = false
        else
            var_0011 = unknown_091BH(var_0005[var_0010], var_0002[var_0010], var_0006[var_0010], var_0004[var_0010], var_0007[var_0010])
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. " Art thou still interested?")
            var_0013 = ask_yes_no()
            if not var_0013 then
                var_0012 = unknown_08F8H(true, 1, 0, var_0004[var_0010], var_0009, var_0008, var_0003[var_0010])
            end
            if var_0012 == 1 then
                add_dialogue("\"Deal!\"")
            elseif var_0012 == 2 then
                add_dialogue("\"I am sorry, " .. var_0000 .. ", not even I could carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou hast not enough gold for that!\"")
            end
            add_dialogue("\"Dost thou want for anything else?\"")
            var_0011 = ask_yes_no()
        end
        var_0001 = var_0011
    end
    restore_answers()
    return
end