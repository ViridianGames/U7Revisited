--- Poison (In Nox). Third Circle. Oracle: usecode Func065E / object#(0x65E).
--- Projectile shape 424 (0x1A8); on hit applies Obj_flags::poisoned = 8.
--- Cast script: face_dir, sfx(0x6E), raise1, strike1×2, delay, attack, standing.

function spell_poison_in_nox_0350(eventid, objectref)
    -- Event 4: projectile 424 impact (objectref = target).
    if eventid == 4 then
        if not is_dead(objectref) then
            set_item_flag(objectref, 8) -- poisoned
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Nox@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if is_npc(target) and is_dead(target) then
        return
    end

    local dir = find_direction(objectref, target)
    -- Exult: set_to_attack(caster, target, 0x1A8=424).
    set_to_attack(objectref, target, 424)
    -- face, dir, sfx 110, raise1, strike1, strike1, attack, standing
    execute_usecode_array(objectref, {17505, 17530, 17511, 17511, 17509, 110, 7768, dir, 7769})
end
