--- Best guess: Implements the mass untrap spell (Vas Des Sanct), disarming traps for nearby party members with visual effects.
function func_0663(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        destroy_item(itemref)
        bark(itemref, "@Vas Des Sanct@")
        if check_spell_requirements() then
            var_0000 = unknown_0018H(itemref) --- Guess: Gets position data
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7) --- Guess: Applies sprite effect
            var_0001 = add_container_items(itemref, {17514, 17519, 8048, 65, 17496, 7791})
            var_0002 = 30
            var_0003 = get_nearby_npcs(var_0002) --- Guess: Gets nearby NPCs
            var_0004 = get_party_members()
            table.insert(var_0004, 356)
            -- Guess: sloop disarms traps for party members
            for i = 1, 5 do
                var_0007 = {5, 6, 7, 3, 80}[i]
                if not (var_0007 == var_0004[1] or var_0007 == var_0004[2] or ...) and random(1, 3) == 1 then
                    var_0002 = check_object_at_position(var_0007, itemref) --- Guess: Checks object at position
                    var_0002 = (var_0002 / 3) + 5
                    var_0001 = add_container_items(var_0007, {var_0002, 1635, 17493, 7715})
                end
            end
        else
            var_0001 = add_container_items(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        set_item_flag(itemref, 3) --- Guess: Sets item flag
    end
end