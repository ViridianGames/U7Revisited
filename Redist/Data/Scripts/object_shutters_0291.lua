-- Closed shutters (type 2)
function object_shutters_0291(eventid, objectref)
    if eventid == 1 then
        if get_object_shape(objectref) == 291 then
            play_sound_effect(100, objectref)
            set_object_shape(objectref, 322)
            set_object_quality(objectref, 2)
        end
    end
end
