--- Fireworks (Bet Ort). Oracle: usecode.dc Func0643 object#(0x643).
--- Linear spell: colorful sparkles around the caster (sprite effect 12).

function spell_douse_bet_ort_0323(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Bet Ort@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 36, 7768})
    obj_sprite_effect(objectref, 12)
end
