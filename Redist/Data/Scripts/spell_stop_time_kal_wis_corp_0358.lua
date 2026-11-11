--- Seance (Kal Wis Corp). Fourth Circle. Oracle: usecode Func0666 / object#(0x666).
--- Untargeted. Opens the ten Skara Brae ghosts until 07:00 if cast before 06:00,
--- otherwise until midnight. Weather 3 (anti-magic sparkle) fizzles the cast.
--- Do not destroy the caster. The function name stays on script 358.

local function set_seance_flags(on)
    for flag = 434, 443 do
        set_flag(flag, on)
    end
end

function spell_stop_time_kal_wis_corp_0358(eventid, objectref)
    if eventid == 2 then
        end_seance()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Kal Wis Corp@")
    -- Func0906 returns false only while get_weather() == 3.
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: reach_1h, raise_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 8037, 17510})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Playback: sfx 67, reach_1h, raise_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 8037, 17510, 67, 7768})

    local pos = get_object_position(objectref)
    if pos then
        -- Green bubbles (13) and the teleport puff (7), two tiles up-left.
        sprite_effect(-1, 0, 0, 0, pos.z - 2, pos.x - 2, 13, pos.y)
        sprite_effect(-1, 0, 0, 0, pos.z - 2, pos.x - 2, 7, pos.y)
    end

    set_seance_flags(true)
    arm_seance()
end
