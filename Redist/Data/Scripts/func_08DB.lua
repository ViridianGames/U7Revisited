--- Best guess: Manages a shop dialogue for purchasing spells from different magical circles, handling spell selection, pricing, and spellbook checks, similar to func_08BB, func_08C3, and func_08C5.
function func_08DB()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    save_answers()
    var_0000 = true
    var_0001 = {185, 155, 135, 115, 85, 65, 45, 25}
    while var_0000 do
        add_dialogue("\"In which circle dost thou wish to study?\"")
        var_0002 = unknown_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        var_0002 = var_0002 - 1
        if var_0002 == 0 then
            break
        elseif var_0002 == 1 then
            var_0003 = {"Awaken All", "Light", "Detect Trap", "Cure", "nothing"}
            var_0004 = {15, 13, 10, 9, 0}
        elseif var_0002 == 2 then
            var_0003 = {"Telekinesis", "Great Light", "Fire Blast", "Destroy Trap", "nothing"}
            var_0004 = {22, 19, 18, 16, 0}
        elseif var_0002 == 3 then
            var_0003 = {"Poison", "Paralyze", "Heal", "Curse", "nothing"}
            var_0004 = {30, 28, 25, 24, 0}
        elseif var_0002 == 4 then
            var_0003 = {"Seance", "Recall", "Mark", "Lightning", "nothing"}
            var_0004 = {38, 36, 34, 33, 0}
        elseif var_0002 == 5 then
            var_0003 = {"Great Heal", "Explosion", "Dance", "Charm", "nothing"}
            var_0004 = {44, 43, 41, 40, 0}
        elseif var_0002 == 6 then
            var_0003 = {"Sleep Field", "Poison Field", "Magic Storm", "Clone", "nothing"}
            var_0004 = {54, 53, 52, 49, 0}
        elseif var_0002 == 7 then
            var_0003 = {"Restoration", "Mass Charm", "Delayed Blast", "Create Gold", "nothing"}
            var_0004 = {63, 61, 58, 56, 0}
        else
            var_0003 = {"Swordstrike", "Summon", "Resurrect", "Armageddon", "nothing"}
            var_0004 = {70, 69, 68, 64, 0}
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
        add_dialogue("\"Wouldst thou like another spell?\"")
        var_0000 = unknown_090AH()
    end
    restore_answers()
    return
end