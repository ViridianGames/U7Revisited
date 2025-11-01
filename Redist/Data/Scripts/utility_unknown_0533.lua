--- Best guess: Checks for ritual items and triggers the endgame sequence if conditions are met.
function utility_unknown_0533(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    var_0000 = find_nearby(8, 40, 1015, 356) --- Guess: Sets NPC location
    var_0001 = false
    -- Guess: sloop checks for ritual items
    for i = 1, 5 do
        var_0004 = {2, 3, 4, 0, 53}[i]
        if get_containerobject_s(243, 797, var_0004, 4) then --- Guess: Gets container items
            var_0001 = var_0004
        end
        if get_containerobject_s(244, 797, var_0004, 4) then --- Guess: Gets container items
            var_0001 = var_0004
        end
    end
    if var_0001 then
        var_0005 = add_containerobject_s(var_0001, {8033, 2, 17447, 17517, 17460, 8025, 3, 7719})
        var_0006 = get_object_position(var_0001) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0006[2], var_0006[1], 17) --- Guess: Applies sprite effect
        play_sound_effect(62) --- Guess: Triggers event
        start_endgame() --- Guess: Starts endgame sequence
    end
    var_0000 = find_nearby(176, 40, 912, 356) --- Guess: Sets NPC location
    -- Guess: sloop destroys items with random effects
    for i = 1, 5 do
        var_0009 = {7, 8, 9, 0, 69}[i]
        var_000A = get_object_position(var_0009) --- Guess: Gets position data
        var_000B = get_object_status(895) --- Guess: Gets item status
        var_000C = update_last_created(var_000A) --- Guess: Updates position
        destroy_object_silent(var_0009) --- Guess: Destroys item silently
        var_0005 = add_containerobject_s(var_000B, {random(50, 150), 17453, 17452, 7715})
    end
    set_schedule_type(15, var_0001) --- Guess: Sets object behavior
end