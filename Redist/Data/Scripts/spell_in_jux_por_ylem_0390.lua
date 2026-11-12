--- Swordstrike (In Jux Por Ylem). Eighth Circle. Oracle: usecode Func0686 / object#(0x686).
--- Targeted. Also event 4 (WEAPON). set_to_attack fires weapon shape 287.
--- The bolt explodes. Do not destroy the caster. The function name stays on script 390.

function spell_in_jux_por_ylem_0390(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@In Jux Por Ylem@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, raise_1h, stand, cast_up, stand, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17505, 17519, 17505, 8037, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    set_to_attack(objectref, target, 287)
    -- Stored reversed. Playback: face, dir, sfx 65, raise_1h, stand, cast_up, stand,
    -- strike_1h, strike_2h, attack, stand.
    execute_usecode_array(objectref, {17505, 17530, 17514, 17511, 17505, 17519, 17505, 8037, 65, 7768, dir, 7769})
end
