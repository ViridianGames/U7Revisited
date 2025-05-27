--- Best guess: Manages a shop dialogue for purchasing spells from different magical circles, handling spell selection, pricing, and spellbook checks, similar to func_08BB and func_08C3.
function func_08C5()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    save_answers()
    var_0000 = true
    var_0001 = {195, 165, 145, 125, 95, 85, 55, 35}
    while var_0000 do
        add_dialogue("\"In which circle dost thou wish to study?\"")
        var_0002 = unknown_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        var_0002 = var_0002 - 1
        if var_0002 == 0 then
            break
        elseif var_0002 == 1 then
            var_0003 = {"Locate", "Light", "Great Douse", "Create Food", "nothing"}
            var_0004 = {14, 13, 11, 8, 0}
        elseif var_0002 == 2 then
            var_0003 = {"Telekinesis", "Protection", "Mass Cure", "Enchant", "nothing"}
            var_0004 = {22, 21, 20, 17, 0}
        elseif var_0002 == 3 then
            var_0003 = {"Sleep", "Protect All", "Swarm", "Heal", "nothing"}
            var_0004 = {31, 27, 26, 25, 0}
        elseif var_0002 == 4 then
            var_0003 = {"Unlock Magic", "Reveal", "Mass Curse", "Conjure", "nothing"}
            var_0004 = {39, 37, 35, 32, 0}
        elseif var_0002 == 5 then
            var_0003 = {"Fire Field", "Invisibility", "Great Heal", "Dispel Field", "nothing"}
            var_0004 = {46, 45, 44, 42, 0}
        elseif var_0002 == 6 then
            var_0003 = {"Sleep Field", "Flame Strike", "Fire Ring", "Cause Fear", "nothing"}
            var_0004 = {54, 51, 50, 48, 0}
        elseif var_0002 == 7 then
            var_0003 = {"Mass Might", "Energy Mist", "Energy Field", "Death Bolt", "nothing"}
            var_0004 = {62, 60, 59, 57, 0}
        else
            var_0003 = {"Time Stop", "Invisible All", "Mass Death", "Death Vortex", "nothing"}
            var_0004 = {71, 67, 66, 65, 0}
        end
        add_dialogue("\"What spell wouldst thou like to buy?\"")
        var_0005 = unknown_090CH(var_0003)
        if var_0005 == 1 then
            add_dialogue("\"Fine.\"")
            break
        end
        var_0006 = var_0004[var_0005]
        var_0007 = var_0001[var_0002]
        var_0008 = var_0003[var_0005]
        add_dialogue("\"The " .. var_0008 .. " spell will cost " .. var_0007 .. " gold.\"")
        var_0009 = unknown_0923H(var_0007, var_0006)
        if var_0009 == 1 then
            add_dialogue("\"Done!\"")
        elseif var_0009 == 2 then
            add_dialogue("\"Thou dost not have a spellbook.\"")
            var_0000 = false
        elseif var_0009 == 3 then
            add_dialogue("\"Thou dost not have enough gold for that!\"")
        elseif var_0009 == 4 then
            add_dialogue("\"Thou dost already have that spell!\"")
        end
        add_dialogue("\"Would you like another spell?\"")
        var_0000 = ask_yes_no()
    end
    restore_answers()
    return
end