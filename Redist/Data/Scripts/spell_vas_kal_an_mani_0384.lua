--- Armageddon (Vas Kal An Mani). Eighth Circle. Oracle: usecode Func0680 / object#(0x680).
--- Untargeted. The second bark, the quake, and the deaths follow the gesture.
--- Do not destroy the caster. The function name stays on script 384.

function spell_vas_kal_an_mani_0384(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Kal An Mani@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: kneel, sleep, kneel, stand, cast_up, cast_out, cast_up, strike_1h, bow, stand.
        execute_usecode_array(objectref, {17505, 17516, 17511, 17519, 17520, 17519, 17505, 17517, 17518, 17517})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, kneel, kneel, kneel, stand, cast_up, cast_out,
    -- sfx 67, cast_up, strike_1h, bow, stand.
    execute_usecode_array(objectref, {17505, 17516, 17511, 17519, 67, 7768, 17520, 17519, 17505, 17517, 17517, 17517, 65, 7768})
    cast_armageddon(objectref)
end
