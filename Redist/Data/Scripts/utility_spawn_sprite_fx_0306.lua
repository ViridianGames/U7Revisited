--- Best guess: Spawns items and applies sprite effects at a specific location, possibly for environmental or visual interactions.
function utility_unknown_0306(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_position(110) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 7) --- Guess: Applies sprite effect
        var_0001 = add_containerobject_s(objectref, {17514, 17520, 17519, 17409, 7715})
        var_0001 = add_containerobject_s(objectref, {4, 1586, 17493, 7715})
    elseif eventid == 2 then
        remove_npc(get_object_ref(110)) --- Guess: Updates object state
    end
end