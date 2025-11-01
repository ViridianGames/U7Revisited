--- Best guess: Implements the wind storm spell (Vas Oort Hur), altering NPC positions with teleportation effects.
function utility_spellteleport_0372(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        destroy_object(objectref)
        bark(objectref, "@Vas Oort Hur@")
        if check_spell_requirements() then
            var_0000 = 70
            set_flag(749, true)
            cast_spell(2) --- Guess: Casts spell
            var_0001 = add_containerobject_s(objectref, {17505, 17514, 17519, 17520, 8047, 65, 7768})
            var_0001 = add_containerobject_s(objectref, {8, 1652, 17493, 7715})
            var_0001 = add_containerobject_s(objectref, {var_0000, 1674, 17493, 7715})
        else
            var_0001 = add_containerobject_s(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        if get_flag(749) then
            var_0002 = 45
            var_0003 = get_nearby_npcs(var_0002) --- Guess: Gets nearby NPCs
            var_0004 = var_0003[random(1, #var_0003)]
            if var_0004 then
                var_0001 = add_containerobject_s(var_0004, {1551, 17493, 7715})
            end
            var_0005 = random(3, 8)
            var_0001 = add_containerobject_s(objectref, {var_0005, 1652, 17493, 7715})
        end
    end
end