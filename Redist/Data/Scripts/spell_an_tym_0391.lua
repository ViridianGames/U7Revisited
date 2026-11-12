--- Time Stop (An Tym). Eighth Circle. Oracle: usecode Func0687 / object#(0x687).
--- Untargeted. stop_time(100) is 25 seconds. The party keeps acting.
--- Do not destroy the caster. The function name stays on script 391.

function spell_an_tym_0391(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Tym@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: strike_2h, cast_out. No spellFails.
        execute_usecode_array(objectref, {17520, 17514})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 67, strike_2h, cast_out.
    execute_usecode_array(objectref, {17520, 17514, 67, 7768})
    stop_time(100)
end
