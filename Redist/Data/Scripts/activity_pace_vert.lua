-- Activity 2: Vertical Pace (north-south)
-- Exult-style: one tile step at a time; about-face when the next tile is blocked.
function activity_pace_vert(npc_id)
    debug_npc(npc_id, "pacing vertically")
    npc_frame(npc_id, 0)  -- leave any sit/sleep pose

    local going_south = true

    local function try_step(dir_south)
        local x, y, z = get_npc_position(npc_id)
        local tx = math.floor(x)
        local tz = math.floor(z)
        local elev = y
        local step = dir_south and 1 or -1
        local nz = tz + step

        if is_blocked(tx, elev, nz) then
            return false
        end

        local request_id = request_pathfind(npc_id, tx + 0.5, elev, nz + 0.5)
        while not is_path_ready(request_id) do
            coroutine.yield()
        end
        start_following_path(npc_id)

        -- Path failed (no waypoints / never started) → treat as blocked.
        if not is_npc_moving(npc_id) then
            local ax, _, az = get_npc_position(npc_id)
            if math.floor(ax) == tx and math.floor(az) == nz then
                return true
            end
            return false
        end

        while not wait_move_end(npc_id) do
            coroutine.yield()
        end

        local ax, _, az = get_npc_position(npc_id)
        return math.floor(ax) == tx and math.floor(az) == nz
    end

    while true do
        if not try_step(going_south) then
            going_south = not going_south
            -- Short about-face pause (Exult uses a couple of frame delays).
            wait(0.35)
            -- If the other direction is also blocked, idle briefly so we don't spin.
            if not try_step(going_south) then
                going_south = not going_south
                wait(0.75)
            end
        end
        coroutine.yield()
    end
end
