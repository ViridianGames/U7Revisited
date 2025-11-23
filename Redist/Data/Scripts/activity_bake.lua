-- Activity 18: Bake
-- NPCs find nearest oven and work on baking
function activity_bake(npc_id)
    

    -- Find nearest oven (TODO: find actual oven shape IDs)
    local oven = find_nearest_shape(npc_id, {360, 361})  -- PLACEHOLDER shape IDs

    if oven then
        -- Walk to oven if not already there
        if distance_to(npc_id, oven) > 2.0 then
            debug_npc(npc_id, "walking to oven")

            local obj_pos = get_object_position(oven)
            if obj_pos then
                local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)
            end

            -- Wait until we reach the oven
            while distance_to(npc_id, oven) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "baking")

    -- Stand at oven
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Work at oven for a while (4-8 seconds)
        local bake_time = 4.0 + (math.random() * 4.0)
        wait(bake_time)

        -- Occasionally turn to get ingredients or check bread
        if math.random() < 0.4 then  -- 40% chance to turn
            local direction = math.random(0, 3)
            
            wait(1.5 + (math.random() * 1.5))

            -- Turn back to oven
            npc_frame(npc_id, 0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
