--- Explosion (book: Vas Ort Flam). Fifth Circle. Oracle: usecode Func066B / object#(0x66B).
--- The caster says "@Vas Flam Hur@", matching the original and Exult.
--- Bolt weapon is shape 78 (fire, damage 16). It flies as fireball shape 856
--- and bursts on impact. Do not destroy the caster.

function spell_likely_a_fireball_0363(eventid, objectref)
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
    bark(objectref, "@Vas Flam Hur@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, cast_up, cast_out, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17520, 8047, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Exult: set_to_attack(caster, target, SHAPE_SPELL_EXPLOSION 78).
    set_to_attack(objectref, target, 78)
    -- Stored reversed. Playback: face, dir, sfx 65, cast_up, cast_out,
    -- strike_1h, strike_1h, attack, standing.
    execute_usecode_array(objectref, {17505, 17530, 17511, 17511, 17520, 8047, 65, 7768, dir, 7769})
end
