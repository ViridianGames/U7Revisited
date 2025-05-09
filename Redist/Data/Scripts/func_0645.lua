--- Best guess: Implements the summon spell (Kal Lor), spawning creatures and setting party flags for combat.
function func_0645(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        destroy_item(itemref)
        if get_flag(39) == false then
            bark(itemref, "@Kal Lor@")
            if check_spell_requirements() then
                set_flag(39, true)
                var_0000 = add_container_items(itemref, {1605, 17493, 17519, 17505, 17517, 17516, 17505, 8047, 64, 7768})
                var_0001 = get_party_members()
                -- Guess: sloop applies flags to party members
                for i = 1, 5 do
                    var_0004 = {2, 3, 4, 1, 43}[i]
                    unknown_008AH(8, var_0004) --- Guess: Sets quest flag
                    unknown_008AH(3, var_0004) --- Guess: Sets quest flag
                    unknown_008AH(2, var_0004) --- Guess: Sets quest flag
                    unknown_008AH(7, var_0004) --- Guess: Sets quest flag
                end
            else
                var_0000 = add_container_items(itemref, {1542, 17493, 17519, 17505, 17517, 17516, 17505, 7791})
            end
        end
    elseif eventid == 2 then
        var_0005 = {0, 1146, 936}
        unknown_003EH(357, var_0005) --- Guess: Sets NPC target
    end
end