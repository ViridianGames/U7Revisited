--- Fireworks (Bet Ort). Oracle: usecode.dc Func0643 object#(0x643).
--- Linear spell: arms-overhead cast (out, up) + SFX 36, then sparkles (sprite 12).
--- Original success: [(byte)0x70, (byte)0x6F, (byte)0x58, 0x0024, (byte)0x55, 0x0643]
---   = out, up, sfx(36), usecode(0x643) → event 2 applies the sprite.

function spell_douse_bet_ort_0323(eventid, objectref)
    if eventid == 2 then
        obj_sprite_effect(objectref, 12)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Bet Ort@")
    if not check_spell_requirements(objectref) then
        -- Failure: out, up
        execute_usecode_array(objectref, {8047, 17520})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Reverse: out, up, sfx(36), usecode(0x643). Sparkles run on event 2 after the poses.
    execute_usecode_array(objectref, {0x643, 17493, 36, 7768, 8047, 17520})
end
