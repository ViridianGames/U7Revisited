-- Open shutters (type 2)
function object_shutters_0322(eventid, objectref)
    if eventid == 1 then
        if get_object_shape(objectref) == 322 then
            play_sound_effect(100, objectref)
            set_object_shape(objectref, 291) -- close them
            set_object_quality(objectref, 2)
        end
    end
end
