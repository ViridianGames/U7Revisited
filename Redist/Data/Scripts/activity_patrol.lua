-- Activity 29: Patrol
-- Exult-style: follow invisible path eggs (shape 607). Frame = route index;
-- quality low 5 bits = action at the egg (pause, sit, wrap, reverse, …).
--
-- Qualities we honor (Exult schedule.cc):
--   0  none
--   1  wrap to start
--   2  pause
--   3  sit (nearest chair)
--   6  brief loiter near egg
--   7/8 about-face pause
--   11 50% reverse direction
--   12 50% skip next egg
--   25 50% wrap to start
-- Flags: bit 6 (64) = forever (repeat last egg)

local PATH_SHAPE = 607
local SEARCH_DIST = 25

local function collect_path_eggs(npc_id)
    -- Exult order: find_nearby(ref, shape, dist, mask)
    local eggs = find_nearby(npc_id, PATH_SHAPE, SEARCH_DIST, 0) or {}
    if #eggs == 0 then
        -- Decompiler-style order as fallback
        eggs = find_nearby(0, SEARCH_DIST, PATH_SHAPE, npc_id) or {}
    end

    local by_frame = {}
    local max_frame = -1
    local nx, ny, nz = get_npc_position(npc_id)

    for i = 1, #eggs do
        local egg_id = eggs[i]
        if egg_id then
            local fr = get_object_frame(egg_id) or 0
            local qual = get_object_quality(egg_id) or 0
            local pos = get_object_position(egg_id)
            if pos then
                local dx = pos.x - nx
                local dz = pos.z - nz
                local d2 = dx * dx + dz * dz
                local prev = by_frame[fr]
                if not prev or d2 < prev.d2 then
                    by_frame[fr] = {
                        id = egg_id,
                        quality = qual,
                        d2 = d2,
                        x = pos.x,
                        y = pos.y,
                        z = pos.z,
                    }
                end
                if fr > max_frame then
                    max_frame = fr
                end
            end
        end
    end

    return by_frame, max_frame
end

local function walk_to_pos(npc_id, x, y, z)
    local request_id = request_pathfind(npc_id, x, y, z)
    while not is_path_ready(request_id) do
        coroutine.yield()
    end
    start_following_path(npc_id)
    while not wait_move_end(npc_id) do
        coroutine.yield()
    end
end

local function walk_to_egg(npc_id, egg)
    walk_to_pos(npc_id, egg.x, egg.y, egg.z)
    -- Close enough? (egg tile itself may be awkward)
    if distance_to and distance_to(npc_id, egg.id) <= 2.0 then
        return true
    end
    local nx, _, nz = get_npc_position(npc_id)
    local dx = math.abs(math.floor(nx) - math.floor(egg.x))
    local dz = math.abs(math.floor(nz) - math.floor(egg.z))
    return math.max(dx, dz) <= 2
end

local function do_sit_at_egg(npc_id)
    if not sit_down or not find_nearest_chair then
        wait(2.0)
        return
    end
    local chair = find_nearest_chair(npc_id)
    if not chair then
        wait(2.0)
        return
    end
    if distance_to(npc_id, chair) > 1.5 then
        local pos = get_object_position(chair)
        if pos then
            walk_to_pos(npc_id, pos.x, pos.y, pos.z)
        end
    end
    sit_down(npc_id, chair)
    -- Exult stays seated ~5–15s on sit path eggs
    wait(5.0 + math.random() * 10.0)
    npc_frame(npc_id, 0)  -- stand / leave chair
end

local function loiter_near(npc_id, center_x, center_y, center_z)
    for _ = 1, 3 do
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 4.0)
        if dest_x then
            walk_to_pos(npc_id, dest_x, dest_y, dest_z)
            wait(1.0 + math.random())
        else
            wait(1.0)
        end
        -- Prefer staying near the egg
        local nx, _, nz = get_npc_position(npc_id)
        if math.max(math.abs(nx - center_x), math.abs(nz - center_z)) > 8 then
            walk_to_pos(npc_id, center_x, center_y, center_z)
        end
    end
end

local function fallback_wander(npc_id)
    local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 12.0)
    if dest_x then
        walk_to_pos(npc_id, dest_x, dest_y, dest_z)
        wait(2.0 + math.random() * 2.0)
    else
        wait(2.0)
    end
end

function activity_patrol(npc_id)
    debug_npc(npc_id, "patrolling")
    npc_frame(npc_id, 0)

    local pathnum = -1
    local dir = 1
    local forever = false
    local last_egg = nil

    while true do
        local by_frame, max_frame = collect_path_eggs(npc_id)

        if max_frame < 0 then
            debug_npc(npc_id, "no path eggs nearby — wandering")
            fallback_wander(npc_id)
            coroutine.yield()
        else
            local egg = nil

            if forever and last_egg then
                egg = last_egg
            else
                -- Advance along the route (Exult: pathnum += dir, bounce at ends)
                pathnum = pathnum + dir
                if pathnum < 0 then
                    pathnum = 0
                    dir = 1
                elseif pathnum > max_frame then
                    pathnum = max_frame
                    dir = -1
                end

                -- Skip holes in the frame sequence (sparse eggs)
                local tries = 0
                while not by_frame[pathnum] and tries <= max_frame + 1 do
                    pathnum = pathnum + dir
                    if pathnum < 0 then
                        pathnum = 0
                        dir = 1
                    elseif pathnum > max_frame then
                        pathnum = max_frame
                        dir = -1
                    end
                    tries = tries + 1
                end
                egg = by_frame[pathnum]
            end

            if not egg then
                debug_npc(npc_id, "path egg missing — wandering")
                fallback_wander(npc_id)
            else
                last_egg = egg
                debug_npc(npc_id, "walking to path egg frame " .. tostring(pathnum))
                walk_to_egg(npc_id, egg)

                local qual = egg.quality or 0
                forever = (qual & 64) ~= 0
                local action = qual & 31

                if action == 1 or (action == 25 and math.random() < 0.5) then
                    -- Wrap to start
                    pathnum = -1
                    dir = 1
                    forever = false
                    wait(0.4)
                elseif action == 2 then
                    wait(0.75)
                elseif action == 3 then
                    do_sit_at_egg(npc_id)
                elseif action == 6 then
                    loiter_near(npc_id, egg.x, egg.y, egg.z)
                elseif action == 7 or action == 8 then
                    wait(0.5)
                elseif action == 11 then
                    if math.random() < 0.5 then
                        dir = -dir
                    end
                    wait(0.25)
                elseif action == 12 then
                    if math.random() < 0.5 then
                        pathnum = pathnum + dir
                    end
                    wait(0.25)
                else
                    -- none / unhandled: brief beat so the route doesn't look frantic
                    wait(0.2 + math.random() * 0.3)
                end
            end
        end

        coroutine.yield()
    end
end
