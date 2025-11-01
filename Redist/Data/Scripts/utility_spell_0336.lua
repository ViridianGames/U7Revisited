--- Best guess: Implements the unlock spell (An Jux), unlocking containers (e.g., chests) with visual effects.
function utility_spell_0336(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_object(objectref)
        bark(objectref, "@An Jux@")
        if check_spell_requirements() then
            var_0002 = add_containerobject_s(objectref, {17514, 17520, 8559, var_0001, 7769})
            var_0003 = find_nearby(176, 2, 200, var_0000) --- Guess: Sets NPC location
            -- Guess: sloop checks item positions
            for i = 1, 5 do
                var_0006 = ({4, 5, 6, 3, 84})[i]
                var_0000 = get_object_position(var_0006) --- Guess: Gets position data
                var_0002 = set_last_created(var_0006) --- Guess: Checks position
                if var_0002 then
                    var_0002 = update_last_created(358) --- Guess: Updates position
                    destroy_object(var_0006)
                    apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 13) --- Guess: Applies sprite effect
                    play_sound_effect(66) --- Guess: Unknown spell operation
                end
            end
            var_0003 = find_nearby(176, 2, 522, objectref) --- Guess: Sets NPC location
            -- Guess: sloop unlocks containers
            for i = 1, 5 do
                var_0006 = ({7, 8, 6, 3, 78})[i]
                var_0000 = get_object_position(var_0006) --- Guess: Gets position data
                if get_object_quality(var_0006) == 255 then
                    var_0002 = set_object_quality(var_0006, 0)
                    apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 13) --- Guess: Applies sprite effect
                    play_sound_effect(66) --- Guess: Unknown spell operation
                end
            end
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 7791})
        end
    end
end