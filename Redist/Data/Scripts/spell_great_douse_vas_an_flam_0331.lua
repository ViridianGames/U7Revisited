--- Great Douse (Vas An Flam). Oracle: usecode.dc Func064B object#(0x64B).
--- Extinguishes nearby lit lights within range 25.
--- Lit shapes → unlit: 701→595, 526→889, 338→336, 435→481.

local DOUSE_MAP = {
    [701] = 595, -- lit torch → unlit
    [526] = 889, -- lit lamppost → unlit
    [338] = 336, -- lit candle → unlit
    [435] = 481, -- lit sconce → unlit
}

function spell_great_douse_vas_an_flam_0331(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas An Flam@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 17509, 7782})
        return
    end

    execute_usecode_array(objectref, {17511, 17509, 7768})

    local range = 25
    local doused = 0
    for lit_shape, unlit_shape in pairs(DOUSE_MAP) do
        local found = find_nearby(objectref, lit_shape, range, 0) or {}
        for _, obj in ipairs(found) do
            set_object_shape(obj, unlit_shape)
            doused = doused + 1
        end
    end

    if doused > 0 then
        play_sound_effect(106, objectref)
    end
end
