--- Unlock Magic (Ex Por). Fourth Circle. Oracle: usecode Func0667 / object#(0x667).
--- Click a door or false wall. Magically locked means frame % 4 == 3
--- ((frame + 1) % 4 == 0). Those frames drop by 3, the closed unlocked state.
--- Ordinary locks (frame % 4 == 2) stay locked. Shapes: 270, 376, 432, 433,
--- 845, 828. The frame changes immediately. Event 2 still drops it by 3 when
--- the piece is still magically locked, so a late usecode call does not
--- subtract twice. No sprite. Do not destroy the caster.

local magic_lock_shapes = {
    [270] = true,
    [376] = true,
    [432] = true,
    [433] = true,
    [845] = true,
    [828] = true,
}

local function magically_locked(target)
    if not target or target == 0 then
        return false
    end
    if not magic_lock_shapes[get_object_shape(target)] then
        return false
    end
    local frame = get_object_frame(target)
    return ((frame + 1) % 4) == 0
end

local function unlock_target(target)
    local frame = get_object_frame(target)
    set_object_frame(target, frame - 3)
end

function spell_lock_ex_por_0359(eventid, objectref)
    if eventid == 2 then
        if magically_locked(objectref) then
            unlock_target(objectref)
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@Ex Por@")
    if not check_spell_requirements(objectref) or not magically_locked(target) then
        -- Playback: face, dir, reach_1h, raise_1h, strike_1h. No sfx, no spellFails.
        execute_usecode_array(objectref, {17511, 8037, 17510, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, reach_1h, raise_1h, strike_1h, sfx 66.
    execute_usecode_array(objectref, {66, 7768, 17511, 8037, 17510, dir, 7769})
    unlock_target(target)
end
