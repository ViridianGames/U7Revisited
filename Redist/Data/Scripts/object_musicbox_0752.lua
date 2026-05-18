-- This script handles the music box: when triggered, plays the music box's instrument track (ID 41).

function object_musicbox_0752(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            set_object_frame(objectref, 1)
            play_instrument(objectref, 41)
            if not npc_id_in_party(-144) then
                set_flag(423, true)
                -- calle 0490H, 1168 (unmapped)
                npc_rowena_0144(get_npc_name(-144))
            end
        else
            set_object_frame(objectref, 0)
            stop_instrument(objectref)
        end
    end
    return
end
