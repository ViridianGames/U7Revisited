--- Flame Strike (Vas In Flam Grav). Sixth Circle. Oracle: usecode Func0673 / object#(0x673).
--- Untargeted. A fire field appears at the feet of each enemy. Do not destroy the caster.
--- The function name stays on script 371.

function spell_vas_in_flam_grav_0371(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas In Flam Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: bow, kneel, bow, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 17516, 17517, 17516})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, bow, kneel, bow, cast_out, strike_2h.
    execute_usecode_array(objectref, {17514, 17520, 17516, 17517, 17516, 65, 7768})
    flame_strike(objectref)
end
