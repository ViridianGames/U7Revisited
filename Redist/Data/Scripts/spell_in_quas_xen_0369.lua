--- Clone (In Quas Xen). Sixth Circle. Oracle: usecode Func0671 / object#(0x671).
--- Targeted. A living NPC or monster is copied onto a nearby tile, on the
--- party's side, about 0.8 seconds later. Do not destroy the caster.
--- The function name stays on script 369.

function spell_in_quas_xen_0369(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    local target = click_on_item()
    halt_scheduled(objectref)
    bark(objectref, "@In Quas Xen@")

    local living = target and target ~= 0 and is_creature(target) and not is_dead(target)
    -- get_item_flag(0, 27) is the decompile's flag check. Object 0 is absent,
    -- so this returns 0 and does not block the cast.
    if not check_spell_requirements(objectref) or not living or get_item_flag(0, 27) == -1 then
        -- Playback: raise_1h, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 17509})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: raise_1h, cast_out, strike_2h.
    execute_usecode_array(objectref, {17514, 17520, 17509})
    schedule_clone(target)
end
