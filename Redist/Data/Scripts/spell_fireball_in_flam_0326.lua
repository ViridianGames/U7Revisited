--- Ignite (In Flam). Oracle: usecode.dc Func0646 object#(0x646).
--- Linear spell: light a targeted unlit torch/lamp/candle/sconce.

local IGNITE_MAP = {
    [595] = 701, -- unlit torch → lit
    [889] = 526, -- unlit lamppost → lit
    [336] = 338, -- unlit candle → lit
    [481] = 435, -- unlit sconce → lit
}

function spell_fireball_in_flam_0326(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 17510, 7768})

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local shape = get_object_shape(target)
    local lit = IGNITE_MAP[shape]
    if lit then
        set_object_shape(target, lit)
        play_sound_effect(46, target)
    end
end
