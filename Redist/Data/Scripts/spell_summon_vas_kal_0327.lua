--- Thunder (Vas Kal). Oracle: usecode.dc Func0647 object#(0x647).
--- Linear spell: thunderclap (SFX 62).

function spell_summon_vas_kal_0327(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Kal@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 62, 7768})
    play_sound_effect(62, objectref)
end
