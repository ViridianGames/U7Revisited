--- Best guess: Manages a shop dialogue for purchasing weapons, handling item selection, pricing, and inventory checks, with a comment on taxes.
function func_08D3()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = unknown_0909H()
    save_answers()
    var_0001 = true
    var_0002 = {"halberd", "two-handed sword", "sword", "mace", "morning star", "spear", "dagger", "nothing"}
    var_0003 = {603, 602, 599, 659, 596, 592, 594, 0}
    var_0004 = {200, 175, 65, 20, 25, 25, 12, 0}
    var_0005 = "a "
    var_0006 = 0
    var_0007 = ""
    var_0008 = 1
    var_0009 = 359
    add_dialogue("\"What weapon wouldst thou like to buy?\"")
    while var_0001 do
        var_0010 = unknown_090CH(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"I completely understand, " .. var_0000 .. ". Ever since the Britannian Tax Council set such outrageous taxes, prices have risen throughout the land.\"")
            var_0001 = false
        else
            var_0011 = unknown_091BH(var_0007, var_0004[var_0010], var_0006, var_0002[var_0010], var_0005)
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. ".\" Is this price acceptable to thee?")
            var_0013 = unknown_090AH()
            if not var_0013 then
                var_0012 = unknown_08F8H(true, 1, 0, var_0004[var_0010], var_0008, var_0009, var_0003[var_0010])
            end
            if var_0012 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0012 == 2 then
                add_dialogue("\"I am sorry, " .. var_0000 .. ", but not even I could carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou hast not enough gold for that!\"")
            end
            add_dialogue("\"Dost thou want for anything else?\"")
            var_0001 = unknown_090AH()
        end
    end
    restore_answers()
    return
end