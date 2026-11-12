--- Great Heal (Vas In Mani). Fifth Circle. Oracle: usecode Func066C / object#(0x66C).
--- Restores the target's Hits to full. Strength is max HP, same as Heal.
--- The caster says "@Vas Mani@". Do not destroy the caster.
--- The function name stays on script 364.

function spell_vas_mani_0364(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Mani@")
    if not check_spell_requirements(objectref) then
        -- Playback: reach_1h, raise_1h, strike_1h. No target yet, so no face. No spellFails.
        execute_usecode_array(objectref, {17511, 8037, 17510})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, reach_1h, raise_1h, strike_1h, sfx 64.
    -- 7724 is finish (0x2C). It sits first so the sfx id 64 is not read as a start delay.
    execute_usecode_array(objectref, {7724, 64, 7768, 17511, 8037, 17510, dir, 7769})

    if not is_npc(target) or is_dead(target) then
        return
    end

    local npc_id = get_npc_number(target)
    if npc_id == nil or npc_id < 0 then
        return
    end

    local max_hp = get_npc_property(npc_id, 0) or 0
    local cur_hp = get_npc_property(npc_id, 3) or 0
    if max_hp <= 0 or cur_hp >= max_hp then
        return
    end

    set_npc_property(npc_id, 3, max_hp)
    spawn_floating_combat_text(target, "+" .. tostring(max_hp - cur_hp), 80, 220, 100)
end
