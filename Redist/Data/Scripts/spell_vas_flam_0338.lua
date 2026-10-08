--- Fire Blast (Vas Flam). Oracle: usecode.dc Func0652 object#(0x652).
--- Second Circle. Oracle: set_to_attack(caster, target, 0x0358) — weapon/shape 856
--- ("fire bolt") flies to the target; frames 0–7 are the spin animation.
--- Do not destroy the caster — earlier decompile used destroy_object(objectref).

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

    if is_npc(target) and is_dead(target) then
        return
    end

    -- fire_projectile(shape, from, to, speed [, damage [, damage_type]])
    -- Shape 856 = fire bolt (spinning frames). Damage 10 fire applied on hit.
    fire_projectile(856, objectref, target, 18, 10, 1)
end
