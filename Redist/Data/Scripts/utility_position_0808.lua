--- Func0828 / 0x828: walk Avatar to a stand point near an object, then run usecode.
---
--- Original: try nearby (dx,dy,dz) offsets via path_run_usecode(loc, fun, item, event).
--- Classic usecode offsets are (dtx, dty, dtz); our positions are engine (x, height, z),
--- so ground-plane offsets map to x/z and lift is left to the pathfinder surface snap.

function utility_position_0808(event_or_item, a2, a3, a4, a5, a6, a7)
    -- Support both usecode order Func0828(item, dx, dy, dz, fun, item2, event)
    -- and the reversed Lua call utility_position_0808(7, item, 788, -3, -1, -1, item)
    local item, dx, dy, dz, fun_shape, eventid
    if type(event_or_item) == "number" and event_or_item <= 16 and a2 ~= nil then
        -- Reversed Lua form (event, item, fun, dz, dy, dx [, item])
        eventid = event_or_item
        item = a2
        fun_shape = a3
        dz = a4
        dy = a5
        dx = a6
    else
        item = event_or_item
        dx, dy, dz = a2, a3, a4
        fun_shape = a5
        eventid = a7 or 7
    end

    if not item then
        return false
    end

    if get_object_container(item) then
        flash_mouse(0)
        return false
    end

    halt_scheduled(get_avatar_ref() or -356)

    local pos = get_object_position(item)
    if not pos then
        return false
    end

    local x = pos[1] or pos.x
    local y = pos[2] or pos.y
    local z = pos[3] or pos.z
    dx = tonumber(dx) or -1
    dy = tonumber(dy) or -1
    dz = tonumber(dz) or -3

    -- Classic (dtx, dty, dtz) → engine (x + dtx, height, z + dty).
    -- Stand on tile centers so pathfinding/arrival thresholds line up.
    local function tile_center(wx, wz)
        return math.floor(wx) + 0.5, math.floor(wz) + 0.5
    end

    local fun = fun_shape or get_object_shape(item)
    local ev = eventid or 7
    local cx, cz = tile_center(x + dx, z + dy)
    local cx2, cz2 = tile_center(x - dx, z + dy)
    local cx3, cz3 = tile_center(x + dx, z - dy)
    local cx4, cz4 = tile_center(x - dx, z - dy)
    local cx5, cz5 = tile_center(x + dx, z)
    local cx6, cz6 = tile_center(x, z + dy)
    local cx7, cz7 = tile_center(x, z)
    local candidates = {
        { cx, y, cz },
        { cx2, y, cz2 },
        { cx3, y, cz3 },
        { cx4, y, cz4 },
        { cx5, y, cz5 },
        { cx6, y, cz6 },
        { cx7, y, cz7 },
    }

    for _, dest in ipairs(candidates) do
        local ok = path_run_usecode(dest, fun, item, ev)
        if ok then
            return true
        end
    end

    flash_mouse(0)
    return false
end
