--- Curse (Des Sanct). Third Circle. Oracle: usecode Func0658 / object#(0x658).
--- Projectile / spell-weapon shape 281 (0x119). On hit sets Obj_flags cursed = 3.
--- Cast: face_dir, sfx(67), out, up, strike2-style poses, UC_ATTACK.

function spell_untrap_des_sanct_0344(eventid, objectref)
    if eventid == 4 then
        if not is_dead(objectref) then
            set_item_flag(objectref, 3) -- cursed
            bark(objectref, "@Cursed!@")
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Des Sanct@")
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
    begin_casting_mode(objectref, 859)
    set_to_attack(objectref, target, 281)
    -- face, dir, sfx 67, out, up, strike2, attack (oracle Func0658)
    execute_usecode_array(objectref, {17530, 17514, 17520, 8047, 67, 8536, dir, 7769})
end
