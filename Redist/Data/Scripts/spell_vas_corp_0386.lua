--- Mass Death (Vas Corp). Eighth Circle. Oracle: usecode Func0682 / object#(0x682).
--- Untargeted. Nearby NPCs die after a short delay. The party is taxed to 2 HP.
--- Do not destroy the caster. The function name stays on script 386.

function spell_vas_corp_0386(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Corp@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: kneel, stand, cast_up, cast_out. No spellFails.
        execute_usecode_array(objectref, {17520, 17519, 17505, 17517})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, kneel, stand, cast_up, cast_out, sfx 67.
    execute_usecode_array(objectref, {67, 7768, 17520, 17519, 17505, 17517, 65, 7768})
    mass_death(objectref)
end
