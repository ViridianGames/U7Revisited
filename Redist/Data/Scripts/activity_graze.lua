-- Activity 17: Graze
-- Animals wander slowly and "graze" (eat grass)
function activity_graze(npc_id)
    
    debug_npc(npc_id, "grazing")

    while true do
        -- Try to find grass to graze on (TODO: find actual grass shape IDs)
        local grass = find_nearest_shape(npc_id, {25, 26, 27})  -- PLACEHOLDER grass shape IDs

        if grass and distance_to(npc_id, grass) < 10.0 then
            -- Walk to grass patch
            local obj_pos = get_object_position(grass)
            if obj_pos then
                local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)
            end

            -- Wait until we reach the grass
            while distance_to(npc_id, grass) > 2.0 do
                coroutine.yield()
            end

            -- Graze for a while (5-10 seconds)
            local graze_time = 5.0 + (math.random() * 5.0)
            wait(graze_time)
        else
            -- No grass nearby - just wander to random spot
            local dest_x, dest_y, dest_z = nil, nil, nil
            local attempts = 0

            while not dest_x and attempts < 10 do
                dest_x, dest_y, dest_z = find_random_walkable(npc_id, 5.0)
                if not dest_x then
                    attempts = attempts + 1
                    coroutine.yield()  -- Yield between attempts
                end
            end

            if dest_x and dest_y and dest_z then
                local request_id = request_pathfind(npc_id, dest_x, dest_y, dest_z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)

                -- Wait until movement completes
                while not wait_move_end(npc_id) do
                    coroutine.yield()
                end

                -- Wait at destination (3-8 seconds)
                local wait_time = 3.0 + (math.random() * 5.0)
                wait(wait_time)
            else
                -- Couldn't find anywhere - just stand still
                debug_npc(npc_id, "couldn't find grazing spot, standing")
                wait(2.0)
            end
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
