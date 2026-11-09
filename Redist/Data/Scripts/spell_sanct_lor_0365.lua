--- Invisibility (Sanct Lor). Fifth Circle.
--- Sets item flag 0 on a selected NPC. The ring of invisibility uses the same flag.
--- Do not destroy the caster.

function spell_sanct_lor_0365(eventid, objectref)
    if eventid == 2 then
        set_item_flag(objectref, 0)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Sanct Lor@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 or not is_npc(target) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    execute_usecode_array(objectref, {17514, 17520, 8047, 109, 7769})
    obj_sprite_effect(target, 13)
    set_item_flag(target, 0)
end
