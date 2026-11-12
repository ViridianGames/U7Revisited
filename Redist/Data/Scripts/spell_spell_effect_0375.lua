--- Tremor (Vas Por Ylem). Sixth Circle. Oracle: usecode Func0677 / object#(0x677).
--- Untargeted. Creatures within 40 tiles stumble, and the ground shakes.
--- Do not destroy the caster. The function name stays on script 375.
--- Dance stays on script 361.

function spell_spell_effect_0375(eventid, objectref)
    if eventid == 2 then
        cause_tremor(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Por Ylem@")
    if not check_spell_requirements(objectref) then
        -- Playback: raise_2h, stand, kneel. No spellFails.
        execute_usecode_array(objectref, {17517, 17505, 17512})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed, and 1655 leads so sfx 67 is not peeled as a start delay.
    -- Playback: raise_2h, stand, kneel, sfx 67, then event 2 (0x677).
    execute_usecode_array(objectref, {1655, 17493, 67, 7768, 17517, 17505, 17512})
end
