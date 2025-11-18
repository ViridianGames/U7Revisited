-- Activity 6: Farm
-- NPCs wander around farm area working the fields
function activity_farm(npc_id)
    
    debug_npc(npc_id, "farming")

    while true do
        -- Try to find a random spot in the farm area (within 8 tiles)
        local dest_x, dest_y, dest_z = nil, nil, nil
        local attempts = 0

        while not dest_x and attempts < 10 do
            dest_x, dest_y, dest_z = find_random_walkable(npc_id, 8.0)
            if not dest_x then
                attempts = attempts + 1
                coroutine.yield()  -- Yield between attempts
            end
        end

        if dest_x and dest_y and dest_z then
            -- Walk to the spot
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Wait until path completes
            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Work at that spot for a while (4-8 seconds)
            local work_time = 4.0 + (math.random() * 4.0)
            wait(work_time)
        else
            -- Couldn't find a spot - just stand and work
            debug_npc(npc_id, "couldn't find farm spot, standing")
            wait(3.0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
