--- Best guess: Applies visual effects and destroys items, likely for a ritual or trap effect.
function func_0713(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = objectref
    if eventid == 2 then
        var_0001 = unknown_0018H(var_0000) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0001[2], var_0001[1], 12) --- Guess: Applies sprite effect
        unknown_000FH(62) --- Guess: Triggers event
        if get_object_frame(var_0000) == 3 then --- Guess: Gets item frame
            set_object_frame(var_0000, 2) --- Guess: Sets item frame
        end
        var_0002 = unknown_0035H(176, 20, 912, var_0000) --- Guess: Sets NPC location
        -- Guess: sloop applies effects and destroys items
        for i = 1, 5 do
            var_0005 = {3, 4, 5, 2, 48}[i]
            apply_sprite_effect(-1, 0, 0, 0, var_0001[2], var_0001[1], 12) --- Guess: Applies sprite effect
            unknown_000FH(62) --- Guess: Triggers event
            destroy_object_silent(var_0005) --- Guess: Destroys item silently
        end
    end
end