-- Activity 5: Eat
-- NPCs find nearest chair (at table) and sit to eat
function activity_eat(npc_id)
    
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair/table nearby - just stand
        debug_npc(npc_id, "has no table for eat activity, standing")
        npc_frame(npc_id, 0)  -- Frame 0 = standing
        while true do
            coroutine.yield()
        end
        return
    end

    -- STATE CHECK: Already sitting at table?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 2.0 then
        -- Already sitting and eating - stay here
        debug_npc(npc_id, "already eating, continuing")
        while true do
            coroutine.yield()
        end
        return
    end

    -- Walk to chair/table if not already there
    if distance_to(npc_id, chair) > 2.0 then
        debug_npc(npc_id, "walking to table")

        local obj_pos = get_object_position(chair)
        if obj_pos then
            local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

            -- Wait for path to be computed
            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            -- Start following the path
            start_following_path(npc_id)
        end

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 2.0 do
            coroutine.yield()
        end
    end

    -- Sit down at table to eat
    debug_npc(npc_id, "sitting down to eat")
    npc_frame(npc_id, 26)  -- Frame 26 = sitting

    -- Stay eating (yield forever until activity changes)
    while true do
        coroutine.yield()
    end
end
