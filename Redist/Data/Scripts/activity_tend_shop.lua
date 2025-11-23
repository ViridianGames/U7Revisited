-- Activity 7: Tend Shop
-- NPCs find nearest counter and stand behind it, occasionally turning
function activity_tend_shop(npc_id)


    -- Find nearest counter (TODO: find actual counter/shop table shape IDs)
    local counter = find_nearest_shape(npc_id, {890, 891})  -- PLACEHOLDER counter shape IDs

    if counter then
        -- Walk to counter if not already there
        if distance_to(npc_id, counter) > 2.0 then
            debug_npc(npc_id, "walking to shop counter")

            local obj_pos = get_object_position(counter)
            if obj_pos then
                local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)
            end

            -- Wait until we reach the counter
            while distance_to(npc_id, counter) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "tending shop")

    -- Stand in place at shop counter
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Stand facing one direction for a while (5-10 seconds)
        local wait_time = 5.0 + (math.random() * 5.0)
        wait(wait_time)

        -- Occasionally turn to face a different direction
        -- frameX controls facing direction (0-3 for different orientations)
        local direction = math.random(0, 3)


        -- Safety yield in case wait() didn't work
        coroutine.yield()
    end
end
