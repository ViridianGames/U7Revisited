--- Energy Mist (In Hur Grav Ylem). Seventh Circle. Oracle: usecode Func067C / object#(0x67C).
--- Targeted. set_to_attack uses weapon shape 399, which starts the cloud instead of a bolt.
--- Do not destroy the caster. The function name stays on script 380.

function spell_in_hur_grav_ylem_0380(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@In Hur Grav Ylem@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, cast_up, cast_out, cast_up, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17519, 17520, 17519, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    set_to_attack(objectref, target, 399)
    -- Stored reversed. Playback: face, dir, cast_up, sfx 65, cast_out, cast_up, strike_2h, attack.
    execute_usecode_array(objectref, {17530, 17514, 17519, 17520, 65, 7768, 17519, dir, 7769})
end
