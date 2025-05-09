--- Best guess: Implements the teleportation spell (Kal Ort Por), applying sprite effects and moving the caster to a target location.
function func_0639(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = add_container_items(itemref, {1593, 17493, 17514, 17520, 17519, 7521, "@Kal Ort Por@", 8018, 1, 17447, 17517, 17456, 7769})
    elseif eventid == 2 then
        var_0001 = unknown_0018H(itemref) --- Guess: Gets position data
        apply_sprite_effect(-1, 2, 0, 0, var_0001[2], var_0001[1], 7) --- Guess: Applies sprite effect
        calle_060FH(itemref) --- External call to teleportation function
        unknown_001DH(15, itemref) --- Guess: Sets object behavior
        unknown_003EH(itemref, {0, 1280, 1450}) --- Guess: Sets NPC target
    end
end