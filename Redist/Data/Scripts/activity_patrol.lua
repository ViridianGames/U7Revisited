-- Activity 29: Patrol
-- NPCs patrol around an area, walking to random positions
function activity_patrol(npc_id)

    debug_npc(npc_id, "patrolling")
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Try to find a random patrol point within 12 tiles
        local dest_x, dest_y, dest_z = nil, nil, nil
        local attempts = 0

        while not dest_x and attempts < 10 do
            dest_x, dest_y, dest_z = find_random_walkable(npc_id, 12.0)
            if not dest_x then
                attempts = attempts + 1
                coroutine.yield()  -- Yield between attempts
            end
        end

        if dest_x and dest_y and dest_z then
            -- Walk to patrol point
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Wait until path completes
            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Pause at patrol point (2-4 seconds)
            local pause_time = 2.0 + (math.random() * 2.0)
            wait(pause_time)
        else
            -- Couldn't find a patrol point - just stand
            debug_npc(npc_id, "couldn't find patrol point, standing")
            wait(2.0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
