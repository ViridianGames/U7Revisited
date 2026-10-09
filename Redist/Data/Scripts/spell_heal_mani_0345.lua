--- Heal (Mani). Third Circle. Oracle: usecode Func0659 / object#(0x659).
--- Restores half of the target's missing Hits (rounded down).
--- Do not destroy the caster — earlier decompile used destroy_object(objectref)
--- and a delayed eventid-2 path that often hit the wrong object.

function spell_heal_mani_0345(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Mani@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    -- Cast FX only (no UC_USECODE delayed heal on the target).
    execute_usecode_array(objectref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 7769})

    if not is_npc(target) or is_dead(target) then
        return
    end

    -- get_npc_property / set_npc_property take NPC id (Avatar is 0).
    local npc_id = get_npc_number(target)
    if npc_id == nil or npc_id < 0 then
        return
    end

    local max_hp = get_npc_property(npc_id, 0) or 0
    local cur_hp = get_npc_property(npc_id, 3) or 0
    if cur_hp > max_hp then
        return
    end

    -- Exult UI_set_npc_prop(health) adds the delta; we set absolute HP.
    local heal_amount = math.floor((max_hp - cur_hp) / 2)
    if heal_amount <= 0 then
        return
    end

    set_npc_property(npc_id, 3, cur_hp + heal_amount)
end
