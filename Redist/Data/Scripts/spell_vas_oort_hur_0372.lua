--- Magic Storm (Vas Oort Hur). Sixth Circle. Oracle: usecode Func0674 / object#(0x674).
--- Untargeted. Rain starts, then lightning strikes one enemy at a time for 14 seconds.
--- Do not destroy the caster. The function name matches this file.

function spell_vas_oort_hur_0372(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Oort Hur@")
    if not check_spell_requirements(objectref) then
        -- Playback: cast_up, cast_out, cast_up, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17519, 17520, 17519})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, cast_up, cast_out, cast_up, strike_2h, stand.
    execute_usecode_array(objectref, {17505, 17514, 17519, 17520, 17519, 65, 7768})
    start_magic_storm(objectref)
end
