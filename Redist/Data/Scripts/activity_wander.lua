-- Activity 12: Wander
-- NPCs wander randomly within a small radius
function activity_wander(npc_id)
    debug_npc(npc_id, "wandering")
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Try to find a random walkable destination within 10 tiles
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 10.0)

        if dest_x and dest_y and dest_z then
            -- Found a valid destination - walk to it
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

            -- Wait a bit at destination (0.5 to 1 game minute)
            local wait_minutes = 5 + (math.random() * 10)
            npc_wait(wait_minutes)
        else
            -- Couldn't find a walkable position - just stand still
            npc_wait(2)  -- Wait 2 game minutes
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
