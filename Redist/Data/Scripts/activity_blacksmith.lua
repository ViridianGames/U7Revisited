-- Activity 13: Blacksmith
-- NPCs find nearest anvil and work at it
function activity_blacksmith(npc_id)
    

    -- Find nearest anvil (TODO: find actual anvil shape IDs)
    local anvil = find_nearest_shape(npc_id, {991, 992})  -- PLACEHOLDER shape IDs

    if anvil then
        -- Walk to anvil if not already there
        if distance_to(npc_id, anvil) > 2.0 then
            debug_npc(npc_id, "walking to anvil")

            local obj_pos = get_object_position(anvil)
            if obj_pos then
                local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)
            end

            -- Wait until we reach the anvil
            while distance_to(npc_id, anvil) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "working as blacksmith")

    -- Stand at anvil working
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Work at anvil for a while (3-7 seconds)
        local work_time = 3.0 + (math.random() * 4.0)
        wait(work_time)

        -- Occasionally turn to get materials or check work
        if math.random() < 0.3 then  -- 30% chance to turn
            local direction = math.random(0, 3)
            
            wait(1.0 + (math.random() * 1.0))

            -- Turn back to anvil
            npc_frame(npc_id, 0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
