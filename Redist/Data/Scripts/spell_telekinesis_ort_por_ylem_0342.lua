--- Telekinesis (Ort Por Ylem). Oracle: usecode.dc Func0656 object#(0x656).
--- Remote-use a non-NPC object (levers, doors, containers, scripted props).
--- Skip set_to_attack / event-4 weapon path — apply use immediately.
--- Do not destroy the caster.

local EXCLUDE = {
    [261] = true, [654] = true, [651] = true, [653] = true, [329] = true,
    [810] = true, [431] = true, [258] = true, [434] = true, [743] = true,
    [470] = true, [740] = true, [873] = true, [583] = true, [696] = true,
    [1011] = true, [785] = true,
}

function spell_telekinesis_ort_por_ylem_0342(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Ort Por Ylem@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 17509, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if is_npc(target) then
        execute_usecode_array(objectref, {17511, 17509, 7781})
        bark(objectref, "@Cannot!@")
        return
    end

    local shape = get_object_shape(target)
    if EXCLUDE[shape] then
        execute_usecode_array(objectref, {17511, 17509, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 17509, 8038, 67, 7769})
    obj_sprite_effect(target, 13)

    if not use_object(target) then
        bark(objectref, "@Nothing happens.@")
    end
end
