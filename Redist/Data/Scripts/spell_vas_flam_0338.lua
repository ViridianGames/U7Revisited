--- Fire Blast (Vas Flam). Oracle: usecode.dc Func0652 object#(0x652).
--- Second Circle. Weapon shape 856 deals 10 fire damage (WEAPONS.DAT).
--- Do not destroy the caster — earlier decompile used destroy_object(objectref).
--- Projectile / set_to_attack path is unimplemented; apply damage immediately.

function spell_vas_flam_0338(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    -- Cast FX only (no UC_USECODE / attack opcode).
    execute_usecode_array(objectref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 7769})

    if not is_npc(target) or is_dead(target) then
        return
    end

    -- apply_damage(base, hit_points, damage_type, target_id [, attacker_id])
    -- damage_type 1 = fire; 10 HP matches weapon 856.
    apply_damage(10, 10, 1, target, objectref)
    obj_sprite_effect(target, 1)
    play_sound_effect(13, target)
end
