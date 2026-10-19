--- Telekinesis (Ort Por Ylem). Oracle: usecode.dc Func0656 object#(0x656).
--- Second Circle: fire projectile shape 443 (0x1BB) at a non-NPC target; on
--- event 4, remotely use the object (levers/doors/containers/scripted props).
--- Shapes in EXCLUDE fizzle on impact (oracle var0003). Levers 787/788/949/950
--- are handled by use_object → Interact(2).

local EXCLUDE = {
    [261] = true, [654] = true, [651] = true, [653] = true, [329] = true,
    [810] = true, [431] = true, [258] = true, [434] = true, [743] = true,
    [470] = true, [740] = true, [873] = true, [583] = true, [696] = true,
    [1011] = true, [785] = true,
}

function spell_telekinesis_ort_por_ylem_0342(eventid, objectref)
    -- Event 4: projectile 443 impact (objectref = target).
    if eventid == 4 then
        if is_npc(objectref) then
            return
        end
        local shape = get_object_shape(objectref)
        if EXCLUDE[shape] then
            return
        end
        use_object(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Ort Por Ylem@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    if is_npc(target) then
        -- Oracle fizzle when the target is an NPC.
        execute_usecode_array(objectref, {1542, 17493, 17511, 17509, dir, 7769})
        return
    end

    -- Exult: set_to_attack(caster, target, 0x1BB=443). UC_ATTACK fires mid-anim.
    set_to_attack(objectref, target, 443)
    -- Oracle success: face, dir, sfx 67, raise1, strike1, UC_ATTACK.
    execute_usecode_array(objectref, {17530, 17511, 17509, 67, 7768, dir, 7769})
end
