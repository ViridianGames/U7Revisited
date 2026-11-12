--- Create Gold (Rel Ylem). Seventh Circle. Oracle: usecode Func0678 / object#(0x678).
--- Targeted. Shape 915 becomes shape 645 one second later. Do not destroy the caster.
--- The function name stays on script 376.

function spell_rel_ylem_0376(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@Rel Ylem@")
    -- Func0906 returns false only while get_weather() == 3.
    if get_weather() == 3 or not check_spell_requirements(objectref) or get_object_shape(target) ~= 915 then
        -- Playback: face, dir, raise_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 8037, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, sfx 66, raise_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 8037, 66, 7768, dir, 7769})
    obj_sprite_effect(target, 13)
    schedule_create_gold(target)
end
