--- Best guess: Plays music (ID 55) and cycles NPC frames (ID 534) for an animation or event trigger.
function object_whistle_0693(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        play_music(objectref, 55)
        if get_object_frame(objectref) == 1 then
            -- calli 007E, 0 (unmapped)
            close_gumps()
            var_0000 = find_nearby_avatar(534)
            while true do
                var_0001 = var_0000
                var_0002 = var_0001
                var_0003 = var_0002
                -- calli 001D, 2 (unmapped)
                set_schedule_type(3, var_0003)
                if not var_0003 then
                    break
                end
            end
        end
    end
    return
end