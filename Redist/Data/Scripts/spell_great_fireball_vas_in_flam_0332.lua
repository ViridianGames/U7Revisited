--- Great Ignite (Vas In Flam). Oracle: usecode.dc Func064C object#(0x64C).
--- Lights nearby unlit lights within range 25.
--- Unlit shapes → lit: 595→701, 889→526, 336→338, 481→435.
--- Filename keeps scriptId 0332 for spellbook lookup (spells.json).

local IGNITE_MAP = {
    [595] = 701, -- unlit torch → lit
    [889] = 526, -- unlit lamppost → lit
    [336] = 338, -- unlit candle → lit
    [481] = 435, -- unlit sconce → lit
}

function spell_great_fireball_vas_in_flam_0332(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas In Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 17510, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 17510, 7768})

    local range = 25
    local lit = 0
    for unlit_shape, lit_shape in pairs(IGNITE_MAP) do
        local found = find_nearby(objectref, unlit_shape, range, 0) or {}
        for _, obj in ipairs(found) do
            set_object_shape(obj, lit_shape)
            lit = lit + 1
        end
    end

    if lit > 0 then
        play_sound_effect(46, objectref)
    end
end
