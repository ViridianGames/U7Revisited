--- Detect Trap (Wis Jux). Oracle: usecode.dc Func064A object#(0x64A).
--- Sparkles nearby traps (shape 200) and quality-255 chests (800 / locked 522).

local function mage_range_bonus(npc_id)
    -- Approximate Func08F6 / utility_npc_prop_halve_calc_1014 from XP.
    local xp = get_npc_property(npc_id, 8) or 0
    local v = math.floor(xp / 100)
    local level = 1
    while v > 0 do
        level = level + 1
        v = math.floor(v / 2)
    end
    return level
end

local function sparkle_trap(obj)
    if obj and obj ~= 0 then
        obj_sprite_effect(obj, 16)
    end
end

function spell_trap_wis_jux_0330(eventid, objectref)
    if eventid == 2 then
        -- Delayed sparkle on a single trap/chest (oracle event 2).
        sparkle_trap(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Wis Jux@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 17509, 7781})
        return
    end

    -- Cast FX only (no UC_USECODE).
    execute_usecode_array(objectref, {17511, 8037, 66, 7768})

    local range = 21 + mage_range_bonus(0)
    -- Exult find_nearby(item, shape, dist, mask); engine accepts that order.
    local traps = find_nearby(objectref, 200, range, 0xB0) or {}
    for _, obj in ipairs(traps) do
        sparkle_trap(obj)
    end

    local chests = find_nearby(objectref, 800, range, 0xB0) or {}
    local locked = find_nearby(objectref, 522, range, 0xB0) or {}
    for _, obj in ipairs(chests) do
        if get_object_quality(obj) == 255 then
            sparkle_trap(obj)
        end
    end
    for _, obj in ipairs(locked) do
        if get_object_quality(obj) == 255 then
            sparkle_trap(obj)
        end
    end
end
