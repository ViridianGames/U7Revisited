--- Fire Ring (Kal Flam Grav). Sixth Circle. Oracle: usecode Func0672 / object#(0x672).
--- Ground target. Twelve fire fields appear around the chosen tile, one after
--- another. Each burns for about 6 to 7 seconds. Do not destroy the caster.
--- The function name stays on script 370.

function spell_kal_flam_grav_0370(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    local dir = find_direction(objectref, tileX, tileZ)
    bark(objectref, "@Kal Flam Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, reach_1h, strike_1h, raise_1h. No spellFails.
        execute_usecode_array(objectref, {17509, 17511, 17510, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, sfx 65, reach_1h, strike_1h, raise_1h.
    execute_usecode_array(objectref, {17509, 17511, 17510, 65, 7768, dir, 7769})
    place_fire_ring(tileX, tileZ, lift)
end
