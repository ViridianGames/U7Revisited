--- Best guess: Implements the teleportation spell (Kal Ort Por), applying sprite effects and moving the caster to a target location.
function utility_spellteleport_0313(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = add_containerobject_s(objectref, {1593, 17493, 17514, 17520, 17519, 7521, "@Kal Ort Por@", 8018, 1, 17447, 17517, 17456, 7769})
    elseif eventid == 2 then
        var_0001 = get_object_position(objectref) --- Guess: Gets position data
        apply_sprite_effect(-1, 2, 0, 0, var_0001[2], var_0001[1], 7) --- Guess: Applies sprite effect
        utility_event_0271(objectref) --- External call to teleportation function
        set_schedule_type(15, objectref) --- Guess: Sets object behavior
        move_object(objectref, {0, 1280, 1450}) --- Guess: Sets NPC target
    end
end