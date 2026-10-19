--- Thunder (Vas Kal). Oracle: usecode.dc Func0647 object#(0x647).
--- Linear Circle: thunderclap SFX 62 during cast poses (raise2, strike2, sfx).
--- Filename keeps scriptId 0327 for spellbook lookup (spells.json).

function spell_summon_vas_kal_0327(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Kal@")
    if not check_spell_requirements(objectref) then
        -- Oracle fizzle: raise2, strike2, usecode(0x606).
        execute_usecode_array(objectref, {1542, 17493, 17514, 17513})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Oracle success: raise2 (0x69), strike2 (0x6A), sfx(0x3E=62).
    -- SFX is embedded in the usecode array so it plays with the cast poses
    -- (no separate play_sound_effect, which double-fired previously).
    execute_usecode_array(objectref, {62, 7768, 17514, 17513})
end
