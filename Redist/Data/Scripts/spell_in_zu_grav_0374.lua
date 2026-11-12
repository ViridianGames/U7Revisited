--- Sleep Field (In Zu Grav). Sixth Circle. Oracle: usecode Func0676 / object#(0x676).
--- Ground target. One shape-902 field. It stays until it puts someone to sleep
--- or Dispel Field removes it. Do not destroy the caster.
--- The function name stays on script 374.

function spell_in_zu_grav_0374(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    local dir = find_direction(objectref, tileX, tileZ)
    bark(objectref, "@In Zu Grav@")
    if not check_spell_requirements(objectref) then
        -- Playback: face, dir, raise_1h, reach_1h, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17510, 17509, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: sfx 65, face, dir, raise_1h, reach_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 17510, 17509, dir, 7769, 65, 7768})

    local field = create_new_object(902)
    if not field then
        return
    end

    if not update_last_created({tileX, lift, tileZ}) then
        destroy_object(field)
        return
    end

    arm_sleep_field(field)
end
