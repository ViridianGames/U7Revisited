--- Best guess: Implements the unlock spell (An Jux), unlocking containers (e.g., chests) with visual effects.
function func_0650(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_item(itemref)
        bark(itemref, "@An Jux@")
        if check_spell_requirements() then
            var_0002 = add_container_items(itemref, {17514, 17520, 8559, var_0001, 7769})
            var_0003 = unknown_0035H(176, 2, 200, var_0000) --- Guess: Sets NPC location
            -- Guess: sloop checks item positions
            for i = 1, 5 do
                var_0006 = {4, 5, 6, 3, 84}[i]
                var_0000 = unknown_0018H(var_0006) --- Guess: Gets position data
                var_0002 = unknown_0025H(var_0006) --- Guess: Checks position
                if var_0002 then
                    var_0002 = unknown_0026H(358) --- Guess: Updates position
                    destroy_item(var_0006)
                    apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 13) --- Guess: Applies sprite effect
                    unknown_000FH(66) --- Guess: Unknown spell operation
                end
            end
            var_0003 = unknown_0035H(176, 2, 522, itemref) --- Guess: Sets NPC location
            -- Guess: sloop unlocks containers
            for i = 1, 5 do
                var_0006 = {7, 8, 6, 3, 78}[i]
                var_0000 = unknown_0018H(var_0006) --- Guess: Gets position data
                if get_item_quality(var_0006) == 255 then
                    var_0002 = set_item_quality(var_0006, 0)
                    apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 13) --- Guess: Applies sprite effect
                    unknown_000FH(66) --- Guess: Unknown spell operation
                end
            end
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
end