--- Best guess: Manages a magic shop interaction, allowing the purchase of spells from various circles, with spellbook and gold checks.
function func_094C()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    save_answers()
    var_0000 = true
    var_0001 = {140, 120, 90, 70, 50, 30}
    while var_0000 do
        add_dialogue("\"To be interested in which circle?\"")
        var_0002 = _SelectIndex({"Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"}) - 1
        if var_0002 == 0 then
            if get_flag(3) then
                add_dialogue("\"To understand.\"")
            else
                add_dialogue("\"To wonder why you bother me so!\"")
            end
            break
        elseif var_0002 == 1 then
            var_0003 = {"Light", "Locate", "Great Douse", "Great Ignite", "nothing"}
            var_0004 = {13, 14, 11, 12, 0}
        elseif var_0002 == 2 then
            var_0003 = {"Great Light", "Destroy Trap", "Enchant", "Fire Blast", "nothing"}
            var_0004 = {19, 16, 17, 18, 0}
        elseif var_0002 == 3 then
            var_0003 = {"Swarm", "Curse", "Poison", "Paralyze", "nothing"}
            var_0004 = {26, 24, 30, 28, 0}
        elseif var_0002 == 4 then
            var_0003 = {"Conjure", "Reveal", "Mass Curse", "Lightning", "nothing"}
            var_0004 = {32, 37, 35, 33, 0}
        elseif var_0002 == 5 then
            var_0003 = {"Fire Field", "Dispel Field", "Explosion", "Mass Sleep", "nothing"}
            var_0004 = {46, 42, 43, 47, 0}
        else
            var_0003 = {"Tremor", "Flame Strike", "Clone", "Fire Ring", "nothing"}
            var_0004 = {55, 51, 49, 50, 0}
        end
        add_dialogue("\"To buy which spell?\"")
        var_0005 = _SelectIndex(var_0003)
        if var_0005 == 1 then
            add_dialogue("\"To be fine.\"")
            break
        end
        var_0006 = var_0004[var_0005]
        var_0007 = var_0001[var_0002]
        var_0008 = var_0003[var_0005]
        add_dialogue("\"To cost " .. var_0007 .. " gold for " .. var_0008 .. " spell.\"")
        var_0009 = unknown_0924H(var_0007, var_0006)
        if var_0009 == 1 then
            add_dialogue("\"To agree!\"")
        elseif var_0009 == 2 then
            add_dialogue("\"To be without a spellbook, human.\"")
            var_0000 = false
        elseif var_0009 == 3 then
            add_dialogue("\"To have not have enough gold for that!\"")
        elseif var_0009 == 4 then
            add_dialogue("\"To see you already have that spell.\"")
        end
        add_dialogue("\"To be interested in another spell?\"")
        var_0000 = _SelectOption()
    end
    restore_answers()
end