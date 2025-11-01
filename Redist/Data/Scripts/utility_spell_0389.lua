--- Best guess: Implements the mass summon spell (Kal Vas Xen), spawning multiple random creatures with weighted probabilities.
function utility_spell_0389(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "Kal Vas Xen")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1669, 8021, 65, 17496, 17514, 17520, 17519, 17505, 7789})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        var_0001 = {706, 661, 354, 514, 274, 883, 505, 501, 154, 533, 337, 504, 528}
        var_0002 = {5, 5, 10, 5, 14, 5, 5, 5, 5, 5, 5, 15, 5}
        var_0003 = {2, 5, 1, 3, 1, 1, 2, 2, 2, 1, 5, 1, 5}
        var_0004 = randomize_array(var_0001) --- Guess: Randomizes array
        var_0005 = random(1, array_size(var_0004))
        var_0006 = random(1, 100)
        while var_0004[var_0005] >= var_0002[var_0005] do
            var_0005 = random(1, array_size(var_0004))
        end
        var_0007 = var_0003[var_0005]
        var_0008 = var_0007 / 2
        if var_0008 < 1 then
            var_0008 = 1
        end
        var_0009 = random(1, var_0008)
        var_0007 = var_0007 + var_0009
        while var_0007 > 0 do
            var_0007 = var_0007 - 1
            var_0000 = spawn_creature(var_0001[var_0005], true) --- Guess: Spawns creature
        end
    end
end