--- Fire Field (In Flam Grav). Fifth Circle. Oracle: usecode Func066E / object#(0x66E).
--- The caster says "@In Flam Grav@". One shape-895 field is placed on the
--- chosen tile (a creature click uses that creature's tile). It burns anyone
--- standing on it and is removed after about 20 seconds.
--- Do not destroy the caster. The function name stays on script 366.

function spell_in_flam_grav_0366(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    local dir = find_direction(objectref, tileX, tileZ)
    bark(objectref, "@In Flam Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, raise_1h, reach_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17510, 8037, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, face, dir, raise_1h, reach_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 17510, 8037, dir, 7769, 65, 7768})

    local field = create_new_object(895)
    if not field then
        return
    end

    -- Engine position is {x, height, z}. The picked tile is already the
    -- cursor tile, so this does not add the original usecode +1,+1.
    if not update_last_created({tileX, lift, tileZ}) then
        destroy_object(field)
        return
    end

    set_object_quality(field, 100)
    arm_fire_field(field)
end
