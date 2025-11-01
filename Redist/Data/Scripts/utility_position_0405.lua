--- Best guess: Places multiple items at the Avatar's position, likely for inventory or crafting purposes.
function utility_position_0405(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = set_object_type_at(740, 356, 10) --- Guess: Sets item type at position
    if var_0000 then
        var_0001 = get_object_frame(var_0000) --- Guess: Gets item frame
        var_0001 = var_0001 - 6
        var_0002 = add_containerobject_s(var_0000, {var_0001, 8006, 2, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 7758})
        var_0003 = add_containerobject_s(356, {8033, 2, 17447, 8039, 1, 7975, 2, 17497, 8036, 1, 17447, 8039, 1, 17447, 8037, 1, 17447, 8038, 1, 17447, 7780})
        var_0004 = add_containerobject_s(objectref, {1, 7750})
        play_sound_effect(40) --- Guess: Triggers event
    end
end