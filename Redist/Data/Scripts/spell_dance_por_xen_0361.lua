--- Dance (Por Xen). Fifth Circle. Oracle: usecode Func0669 / object#(0x669).
--- No target. The caster says "@Por Xen@" and "@Everybody DANCE now!@".
--- When the gesture finishes, people nearby stop and dance.
--- A party caster hits non-party people within 25 tiles. Anyone else hits the party.
--- Intelligence 6 through 24. Do not destroy the caster.
--- The function name stays on script 361.

function spell_dance_por_xen_0361(eventid, objectref)
    if eventid == 2 then
        cause_dancing(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Por Xen@")
    if not check_spell_requirements(objectref) then
        -- Playback: raise_1h, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 8037})
        return
    end

    begin_casting_mode(objectref, 859)
    bark(objectref, "@Everybody DANCE now!@")
    -- Stored reversed. Playback: sfx 67, raise_1h, cast_out, strike_2h, then event 2.
    execute_usecode_array(objectref, {1641, 17493, 17514, 17520, 8037, 67, 7768})
end
