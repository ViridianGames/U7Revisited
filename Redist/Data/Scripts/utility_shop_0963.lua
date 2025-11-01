--- Best guess: Manages a shop dialogue for purchasing spells from different magical circles, similar to func_08BB, with different spell selections and pricing.
function utility_shop_0963()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    save_answers()
    var_0000 = true
    var_0001 = {185, 155, 135, 115, 85, 65, 45, 25}
    while var_0000 do
        add_dialogue("\"In which circle dost thou wish to study?\"")
        var_0002 = utility_unknown_1036({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        var_0002 = var_0002 - 1
        if var_0002 == 0 then
            break
        elseif var_0002 == 1 then
            var_0003 = {"Locate", "Great Ignite", "Detect Trap", "Cure", "nothing"}
            var_0004 = {14, 12, 10, 9, 0}
        elseif var_0002 == 2 then
            var_0003 = {"Wizard Eye", "Protection", "Enchant", "Destroy Trap", "nothing"}
            var_0004 = {23, 21, 17, 16, 0}
        elseif var_0002 == 3 then
            var_0003 = {"Poison", "Peer", "Paralyze", "Swarm", "nothing"}
            var_0004 = {30, 29, 28, 26, 0}
        elseif var_0002 == 4 then
            var_0003 = {"Unlock Magic", "Seance", "Recall", "Mark", "nothing"}
            var_0004 = {39, 38, 36, 34, 0}
        elseif var_0002 == 5 then
            var_0003 = {"Mass Sleep", "Invisibility", "Explosion", "Dispel Field", "nothing"}
            var_0004 = {47, 45, 43, 42, 0}
        elseif var_0002 == 6 then
            var_0003 = {"Tremor", "Poison Field", "Magic Storm", "Fire Ring", "nothing"}
            var_0004 = {55, 53, 52, 50, 0}
        elseif var_0002 == 7 then
            var_0003 = {"Energy Mist", "Energy Field", "Delayed Blast", "Death Bolt", "nothing"}
            var_0004 = {60, 59, 58, 57, 0}
        else
            var_0003 = {"Swordstrike", "Summon", "Mass Death", "Death Vortex", "nothing"}
            var_0004 = {70, 69, 66, 65, 0}
        end
        add_dialogue("\"What spell wouldst thou like to buy?\"")
        var_0005 = utility_unknown_1036(var_0003)
        if var_0005 == 1 then
            add_dialogue("\"Fine.\"")
            break
        end
        var_0006 = var_0004[var_0005]
        var_0007 = var_0001[var_0002]
        var_0008 = var_0003[var_0005]
        add_dialogue("\"The " .. var_0008 .. " spell will cost " .. var_0007 .. " gold.\"")
        var_0009 = utility_spell_1059(var_0007, var_0006)
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
        add_dialogue("\"Wouldst thou like another spell?\"")
        var_0000 = ask_yes_no()
    end
    restore_answers()
    return
end