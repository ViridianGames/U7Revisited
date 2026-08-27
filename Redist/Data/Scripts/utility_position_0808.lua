--- Func0828 / 0x828: walk Avatar next to an object, then run usecode on a (possibly different) item.
---
--- Classic: Func0828(stand_near_item, dx, dy, dz, fun_shape, usecode_item, event)
--- Walk near stand_near_item; on arrival call usecode_item's script with event
--- (fun_shape is the original usecode # / shape — informational for us).
---
--- dx/dy may be a number or parallel offset tables (bucket/well style).

function utility_position_0808(event_or_item, a2, a3, a4, a5, a6, a7)
    local stand_near, dx, dy, dz, fun_shape, usecode_item, eventid
    if type(event_or_item) == "number" and event_or_item <= 16 and a2 ~= nil then
        -- Reversed Lua form (event, item, fun, dz, dy, dx [, usecode_item])
        eventid = event_or_item
        stand_near = a2
        fun_shape = a3
        dz = a4
        dy = a5
        dx = a6
        usecode_item = a7 or stand_near
    else
        -- Classic: (stand_near, dx, dy, dz, fun, usecode_item, event)
        stand_near = event_or_item
        dx, dy, dz = a2, a3, a4
        fun_shape = a5
        usecode_item = a6 or stand_near
        eventid = a7 or 7
    end

    if not stand_near then
        return false
    end

    -- Only block if the *usecode* item is locked in a container we can't reach.
    -- Standing near a world object (well) is fine even if the bucket is already carried.
    if usecode_item and get_object_container(usecode_item) and usecode_item == stand_near then
        flash_mouse(0)
        return false
    end

    halt_scheduled(get_avatar_ref() or -356)

    local pos = get_object_position(stand_near)
    if not pos then
        return false
    end

    local x = pos[1] or pos.x
    local y = pos[2] or pos.y
    local z = pos[3] or pos.z
    dz = tonumber(dz) or -3

    local dx_list, dy_list
    if type(dx) == "table" then
        dx_list = dx
    else
        dx_list = { tonumber(dx) or -1 }
    end
    if type(dy) == "table" then
        dy_list = dy
    else
        dy_list = { tonumber(dy) or -1 }
    end

    local function tile_center(wx, wz)
        return math.floor(wx) + 0.5, math.floor(wz) + 0.5
    end

    local fun = fun_shape or get_object_shape(usecode_item or stand_near)
    local ev = eventid or 7
    local fire_on = usecode_item or stand_near

    local n = math.max(#dx_list, #dy_list)
    local candidates = {}
    for i = 1, n do
        local ddx = dx_list[((i - 1) % #dx_list) + 1] or -1
        local ddy = dy_list[((i - 1) % #dy_list) + 1] or -1
        local cx, cz = tile_center(x + ddx, z + ddy)
        candidates[#candidates + 1] = { cx, y, cz }
    end
    local cx0, cz0 = tile_center(x, z)
    candidates[#candidates + 1] = { cx0, y, cz0 }

    -- Try stands closest to the Avatar first so we don't commit to a long path
    -- into a blocked building tile when a nearer offset would work.
    local av = get_avatar_ref and get_avatar_ref() or get_npc_name(-356)
    local apos = av and get_object_position(av)
    if apos then
        local ax, az = apos[1] or apos.x, apos[3] or apos.z
        table.sort(candidates, function(a, b)
            local da = math.max(math.abs(a[1] - ax), math.abs(a[3] - az))
            local db = math.max(math.abs(b[1] - ax), math.abs(b[3] - az))
            return da < db
        end)
    end

    -- Always try path_run_usecode — do NOT pre-skip with is_blocked.
    -- Tall-solid bake marks many object tiles impassable; path_run_usecode
    -- retargets to a nearby walkable stand (r<=2). Skipping here meant levers
    -- never walked at all.
    for _, dest in ipairs(candidates) do
        local ok = path_run_usecode(dest, fun, fire_on, ev)
        if ok then
            return true
        end
    end

    flash_mouse(0)
    return false
end
