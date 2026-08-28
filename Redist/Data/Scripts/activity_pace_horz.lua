-- Activity 1: Horizontal Pace (east-west)
-- Exult-style: one tile step at a time; about-face when the next tile is blocked.
function activity_pace_horz(npc_id)
    debug_npc(npc_id, "pacing horizontally")
    npc_frame(npc_id, 0)  -- leave any sit/sleep pose

    local going_east = true

    local function try_step(dir_east)
        local x, y, z = get_npc_position(npc_id)
        local tx = math.floor(x)
        local tz = math.floor(z)
        local elev = y
        local step = dir_east and 1 or -1
        local nx = tx + step

        if is_blocked(nx, elev, tz) then
            return false
        end

        local request_id = request_pathfind(npc_id, nx + 0.5, elev, tz + 0.5)
        while not is_path_ready(request_id) do
            coroutine.yield()
        end
        start_following_path(npc_id)

        -- Path failed (no waypoints / never started) → treat as blocked.
        if not is_npc_moving(npc_id) then
            local ax, _, az = get_npc_position(npc_id)
            if math.floor(ax) == nx and math.floor(az) == tz then
                return true
            end
            return false
        end

        while not wait_move_end(npc_id) do
            coroutine.yield()
        end

        local ax, _, az = get_npc_position(npc_id)
        return math.floor(ax) == nx and math.floor(az) == tz
    end

    while true do
        if not try_step(going_east) then
            going_east = not going_east
            -- Short about-face pause (Exult uses a couple of frame delays).
            wait(0.35)
            -- If the other direction is also blocked, idle briefly so we don't spin.
            if not try_step(going_east) then
                going_east = not going_east
                wait(0.75)
            end
        end
        coroutine.yield()
    end
end
