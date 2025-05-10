--- Best guess: Implements the douse spell (Por Ort Wis), extinguishing light sources or effects with teleportation effects.
function func_0657(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        bark(objectref, "@Por Ort Wis@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1623, 17493, 17514, 17519, 8048, 67, 17496, 7791})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        var_0001 = unknown_0018H(objectref) --- Guess: Gets position data
        teleport_object(objectref, 200) --- Guess: Teleports object
    end
end