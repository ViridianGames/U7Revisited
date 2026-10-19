--- Ignite (In Flam). Oracle: usecode.dc Func0646 object#(0x646).
--- Linear Circle. Lights a targeted unlit torch/lamp/candle/sconce via projectile
--- shape 280 (0x118), same pattern as Douse (An Flam) projectile 540.
--- Cast script: face_dir, up, out, strike2, UC_ATTACK.

local IGNITE_MAP = {
    [595] = 701, -- unlit torch → lit
    [889] = 526, -- unlit lamppost → lit
    [336] = 338, -- unlit candle → lit
    [481] = 435, -- unlit sconce → lit
}

function spell_fireball_in_flam_0326(eventid, objectref)
    -- Event 4: projectile 280 impact (objectref = target).
    if eventid == 4 then
        local shape = get_object_shape(objectref)
        local lit = IGNITE_MAP[shape]
        if lit then
            set_object_shape(objectref, lit)
            play_sound_effect(46, objectref)
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Flam@")
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
    -- Exult: set_to_attack(caster, target, 0x118=280). UC_ATTACK fires after last pose.
    set_to_attack(objectref, target, 280)
    -- Reverse array: attack, strike2, out, up, face_dir
    -- Oracle Func0646: face_dir, dir, up(0x6F), out(0x70), strike2(0x6A), UC_ATTACK.
    execute_usecode_array(objectref, {17530, 17514, 17520, 8047, dir, 7769})
end
