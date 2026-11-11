--- Lightning (Ort Grav). Fourth Circle. Oracle: usecode Func0661 / object#(0x661).
--- Bolt is weapon shape 807: damage 8, lightning type, armor ignored, no strength add.
--- Cast script: face, raise 1h, cast up, sfx 65, cast out, strike 2h, strike 2h, attack, stand.
--- UC_ATTACK fires the bolt on that step. Do not destroy the caster.

function spell_lightning_ort_grav_0353(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Ort Grav@")
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
    -- Exult: set_to_attack(caster, target, SHAPE_LIGHTNING 807).
    set_to_attack(objectref, target, 807)
    -- Stored reversed; the engine flips it back to the gesture above.
    execute_usecode_array(objectref, {17505, 17530, 17514, 17514, 8048, 65, 17496, 17519, 8549, dir, 7769})
end
