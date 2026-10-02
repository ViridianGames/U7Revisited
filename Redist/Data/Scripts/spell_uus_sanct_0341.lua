--- Protection (Uus Sanct). Oracle: usecode.dc Func0655 object#(0x655).
--- Sets item flag 9 (protection) on a selected NPC.
--- Do not destroy the caster.

function spell_uus_sanct_0341(eventid, objectref)
    if eventid == 2 then
        set_item_flag(objectref, 9) -- protection
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Uus Sanct@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17509, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 or not is_npc(target) then
        execute_usecode_array(objectref, {17514, 17509, 7781})
        return
    end

    execute_usecode_array(objectref, {17514, 17509, 8047, 109, 7769})
    obj_sprite_effect(target, 13)
    set_item_flag(target, 9)
    bark(target, "@Protected!@")
end
