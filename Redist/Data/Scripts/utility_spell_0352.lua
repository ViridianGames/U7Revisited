--- Best guess: Implements the summon creature spell (Kal Xen), spawning a random creature from a predefined list.
function utility_spell_0352(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        destroy_object(objectref)
        bark(objectref, "@Kal Xen@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1632, 17493, 17511, 17510, 8037, 65, 7768})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 17510, 7781})
        end
    elseif eventid == 2 then
        var_0001 = {537, 502, 530, 510, 523, 811, 716}
        var_0002 = array_size(var_0001)
        var_0003 = selectrandom_creature(356) --- Guess: Selects random creature
        if var_0003 > var_0002 then
            var_0003 = var_0002
        end
        if var_0003 < 2 then
            var_0003 = 2
        end
        var_0004 = var_0003 / 2
        if var_0004 < 1 then
            var_0004 = 1
        end
        var_0005 = random(var_0004, var_0003)
        while var_0005 > 0 do
            var_0005 = var_0005 - 1
            var_0006 = random(var_0004, var_0003)
            var_0007 = var_0001[var_0006]
            var_0008 = spawn_creature(var_0007, false) --- Guess: Spawns creature
        end
    end
end