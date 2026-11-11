--- Reveal (Wis Quas). Fourth Circle. Oracle: usecode Func0665 / object#(0x665).
--- Untargeted. Searches around the Avatar, not the caster. Twelve probes of
--- radius 7 cover a block about 45 by 33 tiles. Anything there with the
--- invisible flag (flag 0) loses it. Green bubbles (sprite 13) mark each one.
--- If nothing is invisible, the bubbles play on the caster. Do not destroy the caster.

local offset_x = { -15, -15, -15, -5, -5, -5, 5, 5, 5, 15, 15, 15 }
local offset_z = { -7, 2, 11, -7, 2, 11, -7, 2, 11, -7, 2, 11 }
local kProbeRadius = 7
-- Farthest probe is 15, plus the probe radius.
local kSearchRadius = 22

local function tile_dist(ax, az, bx, bz)
    local dx = math.floor(math.abs(ax - bx))
    local dz = math.floor(math.abs(az - bz))
    if dz > dx then
        return dz
    end
    return dx
end

local function in_reveal_area(origin, pos)
    for i = 1, 12 do
        local dist = tile_dist(origin.x + offset_x[i], origin.z + offset_z[i], pos.x, pos.z)
        if dist <= kProbeRadius then
            return true
        end
    end
    return false
end

local function reveal_area(caster)
    local center = get_avatar_ref()
    if not center or center == -1 then
        center = caster
    end
    local origin = get_object_position(center)
    if not origin then
        obj_sprite_effect(caster, 13)
        return
    end

    local nearby = find_nearby(center, -359, kSearchRadius, 32) or {}
    nearby[#nearby + 1] = center

    local seen = {}
    local found = false
    for _, id in ipairs(nearby) do
        if id and id ~= -1 and not seen[id] and get_item_flag(id, 0) == 1 then
            seen[id] = true
            local pos = get_object_position(id)
            if pos and in_reveal_area(origin, pos) then
                clear_item_flag(id, 0)
                obj_sprite_effect(id, 13)
                found = true
            end
        end
    end

    if not found then
        obj_sprite_effect(caster, 13)
    end
end

function spell_reveal_wis_quas_0357(eventid, objectref)
    if eventid == 2 then
        clear_item_flag(objectref, 0)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Wis Quas@")
    if not check_spell_requirements(objectref) then
        -- raise, reach, strike. No call to spellFails (0x606).
        execute_usecode_array(objectref, {17511, 17510, 8037})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Reversed. Playback: sfx 67, raise_1h, reach_1h, strike_1h.
    execute_usecode_array(objectref, {17511, 17510, 8037, 67, 7768})
    reveal_area(objectref)
end
