--- Cause Fear (Quas Wis). Sixth Circle. Oracle: usecode Func0670 / object#(0x670).
--- Untargeted. Living creatures within 25 tiles, except the party, flee the Avatar
--- when their intelligence is above 5. Do not destroy the caster.
--- The function name stays on script 368.

function spell_quas_wis_0368(eventid, objectref)
    if eventid == 2 then
        cause_fear(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Quas Wis@")
    if not check_spell_requirements(objectref) then
        -- Playback: kneel, stand, reach_1h, raise_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17509, 17510, 17505, 8045})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, kneel, stand, reach_1h, raise_1h,
    -- strike_1h, then event 2 (0x670).
    execute_usecode_array(objectref, {1648, 17493, 17511, 17509, 17510, 17505, 8045, 65, 7768})
end
