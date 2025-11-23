-- Activity 23: Waiter
-- NPCs move between tables serving food and drinks
function activity_waiter(npc_id)

    debug_npc(npc_id, "waiting tables")
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Find a random table to serve within 15 tiles
        -- Tables are typically shapes 890, 891, 633, 1003, 1018, etc.
        local table_shapes = {890, 891, 633, 1003, 1018, 847}
        local table = find_nearest_shape(npc_id, table_shapes)

        if table then
            -- Walk to the table if not already near it
            if distance_to(npc_id, table) > 2.0 then
                debug_npc(npc_id, "walking to table")

                local obj_pos = get_object_position(table)
                if obj_pos then
                    local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                    -- Wait for path to be computed
                    while not is_path_ready(request_id) do
                        coroutine.yield()
                    end

                    -- Start following the path
                    start_following_path(npc_id)

                    -- Wait until we reach the table
                    while not wait_move_end(npc_id) do
                        coroutine.yield()
                    end
                end
            end

            -- Stand at table briefly (simulating serving/clearing)
            debug_npc(npc_id, "serving table")
            npc_frame(npc_id, 0)

            -- Wait 3-6 game minutes at the table
            local serve_time = 3 + (math.random() * 3)
            npc_wait(serve_time)

        else
            -- No tables found - wander to a random location instead
            debug_npc(npc_id, "wandering (no tables nearby)")
            local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 10.0)

            if dest_x and dest_y and dest_z then
                local request_id = request_pathfind(npc_id, dest_x, dest_y, dest_z)

                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                start_following_path(npc_id)

                while not wait_move_end(npc_id) do
                    coroutine.yield()
                end
            end

            -- Brief pause
            npc_wait(2)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
