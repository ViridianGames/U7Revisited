--- Best guess: Spawns items and applies sprite effects, likely for transformation visuals tied to Erethian's shape-shifting.
function utility_unknown_0408(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_object_position(objectref) --- Guess: Gets position data
    var_0001 = find_nearby(4, 1, 521, objectref) --- Guess: Sets NPC location
    var_0002 = find_nearby(4, 1, 500, objectref) --- Guess: Sets NPC location
    if var_0001 then
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 13) --- Guess: Applies sprite effect
        play_sound_effect(67) --- Guess: Triggers event
        destroy_object_silent(var_0001) --- Guess: Destroys item silently
        set_object_frame(objectref, 28) --- Guess: Sets item frame
        var_0003 = add_containerobject_s(objectref, {1686, 8021, 3, 17447, 8033, 4, 17447, 8044, 5, 17447, 7789})
    end
    if var_0002 then
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 17) --- Guess: Applies sprite effect
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 7) --- Guess: Applies sprite effect
        play_sound_effect(62) --- Guess: Triggers event
        destroy_object_silent(var_0002) --- Guess: Destroys item silently
        set_object_frame(objectref, 30) --- Guess: Sets item frame
        var_0003 = add_containerobject_s(objectref, {1686, 8021, 3, 17447, 8033, 4, 17447, 8048, 5, 17447, 7791})
    end
end