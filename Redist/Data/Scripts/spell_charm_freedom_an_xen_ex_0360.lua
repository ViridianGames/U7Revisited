--- Charm (An Xen Ex). Fifth Circle. Oracle: usecode Func0668 / object#(0x668).
--- Targeted. set_to_attack fires weapon shape 80 (damage 0, charm power).
--- The bolt art is that row's projectile, shape 540. Weather 3 fizzles.
--- Do not destroy the caster. The function name stays on script 360.

function spell_charm_freedom_an_xen_ex_0360(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if is_npc(target) and is_dead(target) then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@An Xen Ex@")
    -- Func0906 returns false only while get_weather() == 3.
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, raise_1h, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 8037, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Exult: set_to_attack(caster, target, SHAPE_SPELL_CHARM 80).
    set_to_attack(objectref, target, 80)
    -- Stored reversed. Playback: face, dir, sfx 68, raise_1h, cast_out, strike_2h, attack.
    execute_usecode_array(objectref, {17530, 17514, 17520, 8037, 68, 7768, dir, 7769})
end
