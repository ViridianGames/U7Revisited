--- Energy Field (In Sanct Grav). Seventh Circle. Oracle: usecode Func067B / object#(0x67B).
--- Ground target. One shape-768 wall on the chosen tile. It does not shock.
--- Do not destroy the caster. The function name stays on script 379.

function spell_in_sanct_grav_0379(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    bark(objectref, "@In Sanct Grav@")
    -- Fail when magic is blocked or the tile has no walkable surface. No spellFails.
    -- The three poses are the same either way: raise_1h, reach_1h, strike_1h.
    if get_weather() == 3 or not check_spell_requirements(objectref) or not energy_field_tile_open(tileX, tileZ, lift) then
        execute_usecode_array(objectref, {17511, 17510, 8037})
        return
    end

    begin_casting_mode(objectref, 859)
    execute_usecode_array(objectref, {17511, 17510, 8037})
    place_energy_field(tileX, tileZ, lift)
end
