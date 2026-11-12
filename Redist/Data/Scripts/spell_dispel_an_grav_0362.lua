--- Dispel Field (An Grav). Fifth Circle. Oracle: usecode Func066A / object#(0x66A).
--- The caster says "@An Grav@". The clicked object is removed when it is an
--- energy field (768), fire field (895), poison field (900), or sleep field (902).
--- Any other target stays. Do not destroy the caster.
--- The function name stays on script 362.

local FIELD_SHAPES = {
    [768] = true, -- energy field
    [895] = true, -- fire field
    [900] = true, -- poison field
    [902] = true, -- sleep field
}

function spell_dispel_an_grav_0362(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@An Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, cast_up, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 8047, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, face, dir, cast_up, cast_out, strike_2h.
    execute_usecode_array(objectref, {17514, 17520, 8047, dir, 7769, 65, 7768})

    local shape = get_object_shape(target)
    if not FIELD_SHAPES[shape] then
        return
    end

    halt_scheduled(target)
    destroy_object(target)
end
