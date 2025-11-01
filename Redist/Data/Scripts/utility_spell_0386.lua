--- Best guess: Implements the mass death spell (Vas Corp), killing nearby NPCs except party members and specific exclusions (e.g., Lord British, Batlin).
function utility_spell_0386(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Vas Corp@")
        if check_spell_requirements() then
            var_0000 = get_object_position(objectref) --- Guess: Gets position data
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7) --- Guess: Applies sprite effect
            var_0001 = add_containerobject_s(objectref, {67, 17496, 17520, 17519, 17505, 8045, 65, 7768})
            var_0002 = 25
            var_0003 = find_nearby(4, var_0002, -1, objectref) --- Guess: Sets NPC location
            var_0004 = get_party_members()
            var_0004 = append_to_array(var_0004, 23) --- Guess: Adds Lord British to array
            var_0004 = append_to_array(var_0004, 26) --- Guess: Adds Batlin to array
            var_0005 = false
            -- Guess: sloop kills nearby NPCs
            for i = 1, 5 do
                var_0008 = {6, 7, 8, 3, 73}[i]
                if not (var_0008 == var_0004[1] or var_0008 == var_0004[2] or ...) then
                    var_0002 = check_object_at_position(var_0008, objectref) --- Guess: Checks object at position
                    var_0002 = var_0002 / 3 + 5
                    destroyobject_(var_0008)
                    var_0001 = add_containerobject_s(var_0008, {var_0002, 1666, 17493, 7715})
                    var_0005 = true
                end
            end
            if var_0005 then
                var_0004 = get_party_members()
                -- Guess: sloop damages party members
                for i = 1, 5 do
                    var_000B = {9, 10, 11, 4, 29}[i]
                    var_000C = get_npc_property(3, var_000B) --- Guess: Gets NPC property
                    damage_npc(var_000B, var_000C - 2) --- Guess: Damages NPC
                end
            end
        else
            var_0001 = add_containerobject_s(objectref, {1542, 17493, 17520, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        var_000D = get_item_flag(14, objectref) --- Guess: Checks NPC status
        if var_000D == false then
            var_000C = get_npc_property(3, objectref) --- Guess: Gets NPC property
            damage_npc(objectref, var_000C - 2) --- Guess: Damages NPC
            damage_npc(objectref, 50) --- Guess: Damages NPC
        end
    end
end