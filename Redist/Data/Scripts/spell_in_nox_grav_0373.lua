--- Poison Field (In Nox Grav). Sixth Circle. Oracle: usecode Func0675 / object#(0x675).
--- Ground target. One shape-900 field. It stays until it poisons someone or
--- Dispel Field removes it. Do not destroy the caster.
--- The function name stays on script 373.

function spell_in_nox_grav_0373(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    local dir = find_direction(objectref, tileX, tileZ)
    bark(objectref, "@In Nox Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, raise_1h, reach_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17510, 17509, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, sfx 110, raise_1h, reach_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 17510, 17509, 110, 7768, dir, 7769})

    local field = create_new_object(900)
    if not field then
        return
    end

    if not update_last_created({tileX, lift, tileZ}) then
        destroy_object(field)
        return
    end

    arm_poison_field(field)
end
