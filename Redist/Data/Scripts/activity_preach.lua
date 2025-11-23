-- Activity 28: Preach
-- NPCs find nearest pulpit and stand preaching, turning to address congregation
function activity_preach(npc_id)

    -- Find nearest pulpit (TODO: find actual pulpit shape IDs)
    local pulpit = find_nearest_shape(npc_id, {999})  -- PLACEHOLDER shape ID

    if pulpit then
        -- Walk to pulpit if not already there
        if distance_to(npc_id, pulpit) > 2.0 then
            debug_npc(npc_id, "walking to pulpit")

            local obj_pos = get_object_position(pulpit)
            if obj_pos then
                local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

                -- Wait for path to be computed
                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                -- Start following the path
                start_following_path(npc_id)
            end

            -- Wait until we reach the pulpit
            while distance_to(npc_id, pulpit) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "preaching")

    -- Stand at pulpit
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Face forward for a while (5-10 seconds)
        npc_frame(npc_id, 0)
        local speak_time = 5.0 + (math.random() * 5.0)
        wait(speak_time)

        -- Turn to face congregation on left side
        
        wait(2.0 + (math.random() * 2.0))

        -- Turn to face congregation on right side
        
        wait(2.0 + (math.random() * 2.0))

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
