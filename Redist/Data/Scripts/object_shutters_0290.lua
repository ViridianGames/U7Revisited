-- Closed shutters (type 1)
function object_shutters_0290(eventid, objectref)
    if eventid == 1 then
        if get_object_shape(objectref) == 290 then
            play_sound_effect(100, objectref)
            set_object_shape(objectref, 372)
            set_object_quality(objectref, 2)
        end
    end
end
