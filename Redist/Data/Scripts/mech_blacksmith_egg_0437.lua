--- Best guess: Manages an egg in a blacksmith's house, checking nearby items (types 270, 376) and triggering external functions based on their properties.
-- 270 - Horizontal door
-- 376 - Vertical door
function utility_unknown_0437(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = find_nearest_object_of_shape(0, 376)
    set_object_shape(var_0000, 270)
    play_sound_effect(0)
end

