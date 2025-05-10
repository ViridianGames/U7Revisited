--- Best guess: Implements the stop time spell (Kal Wis Corp), freezing time for a duration based on game time with multiple flags.
function func_0666(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Kal Wis Corp@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {17511, 17509, 8038, 67, 7768})
            var_0001 = unknown_0018H(objectref) --- Guess: Gets position data
            var_0002 = var_0001[1] - 2
            var_0003 = var_0001[2] - 2
            apply_sprite_effect(-1, 0, 0, 0, var_0003, var_0002, 13) --- Guess: Applies sprite effect
            apply_sprite_effect(-1, 0, 0, 0, var_0003, var_0002, 7) --- Guess: Applies sprite effect
            set_flag(434, true)
            set_flag(435, true)
            set_flag(436, true)
            set_flag(437, true)
            set_flag(438, true)
            set_flag(439, true)
            set_flag(440, true)
            set_flag(441, true)
            set_flag(442, true)
            set_flag(443, true)
            set_flag(439, true)
            var_0004 = get_time_hour() --- Guess: Gets current hour
            var_0005 = get_time_minute() --- Guess: Gets current minute
            if var_0004 < 6 then
                var_0006 = (6 - var_0004) * 60
                var_0006 = var_0006 + (60 - var_0005)
                var_0006 = var_0006 * 25
            else
                var_0006 = (23 - var_0004) * 60
                var_0006 = var_0006 + (60 - var_0005)
                var_0006 = var_0006 * 25
            end
            var_0000 = add_containerobject_s(objectref, {var_0006, 1638, 17493, 17452, 7715})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        set_flag(434, false)
        set_flag(435, false)
        set_flag(436, false)
        set_flag(437, false)
        set_flag(438, false)
        set_flag(439, false)
        set_flag(440, false)
        set_flag(441, false)
        set_flag(442, false)
        set_flag(443, false)
        set_flag(439, false)
    end
end