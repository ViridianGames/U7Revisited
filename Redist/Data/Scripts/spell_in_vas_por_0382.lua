--- Mass Might (In Vas Por). Seventh Circle. Oracle: usecode Func067E / object#(0x67E).
--- Untargeted. The party gains strength, dexterity, intelligence, and combat.
--- Do not destroy the caster. The function name matches the file.

function spell_in_vas_por_0382(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Vas Por@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: cast_up, cast_out, cast_up, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17519, 17520, 17519})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: cast_up, sfx 64, cast_out, cast_up, strike_2h.
    -- 64 is not the first value, so it is not peeled as a start delay.
    execute_usecode_array(objectref, {17514, 17519, 17520, 64, 7768, 17519})
    mass_might(objectref)
end
