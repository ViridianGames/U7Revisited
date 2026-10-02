--- Douse (An Flam). Oracle: usecode.dc Func0642 object#(0x642).
--- Linear spell: extinguish a targeted lit light (torch/lamp/candle/sconce).

local DOUSE_MAP = {
    [701] = 595, -- lit torch → unlit
    [526] = 889, -- lit lamppost → unlit
    [338] = 336, -- lit candle → unlit
    [435] = 481, -- lit sconce → unlit
}

function spell_dispel_fire_an_flam_0322(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 17509, 7768})

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local shape = get_object_shape(target)
    local unlit = DOUSE_MAP[shape]
    if unlit then
        set_object_shape(target, unlit)
        play_sound_effect(46, target)
    end
end
