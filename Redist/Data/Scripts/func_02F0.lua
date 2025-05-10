--- Best guess: Toggles a music box to play music (ID 41) or stop (ID 255), setting a flag and calling an external function, likely for ambiance.
function func_02F0(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            set_object_frame(objectref, 1)
            play_music(objectref, 41)
            if not unknown_08F7H(-144) then
                set_flag(423, true)
                -- calle 0490H, 1168 (unmapped)
                unknown_0490H(unknown_001BH(-144))
            end
        else
            set_object_frame(objectref, 0)
            play_music(objectref, 255)
        end
    end
    return
end