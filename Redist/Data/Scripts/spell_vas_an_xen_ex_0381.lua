--- Mass Charm (Vas An Xen Ex). Seventh Circle. Oracle: usecode Func067D / object#(0x67D).
--- Untargeted. Nearby creatures may be charmed. Do not destroy the caster.
--- The function name stays on script 381.

function spell_vas_an_xen_ex_0381(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas An Xen Ex@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: cast_up, cast_out, cast_up, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17519, 17520, 17519})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, cast_up, cast_out, cast_up, strike_2h.
    execute_usecode_array(objectref, {17514, 17519, 17520, 17519, 65, 7768})
    mass_charm(objectref)
end
