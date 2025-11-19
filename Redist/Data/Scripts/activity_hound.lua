-- Activity 9: Hound
-- NPCs (dogs/animals) wander around sniffing and exploring
function activity_hound(npc_id)

    debug_npc(npc_id, "hounding")
    npc_frame(npc_id, 0)

    while true do
        -- Find a random nearby position to investigate (smaller radius than wander)
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 6.0)

        if dest_x and dest_y and dest_z then
            -- Walk to the position
            local request_id = request_pathfind(npc_id, dest_x, dest_y, dest_z)

            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            start_following_path(npc_id)

            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Sniff around at destination (short pause)
            local sniff_time = 1 + (math.random() * 2)
            npc_wait(sniff_time)
        else
            -- No walkable position found, just wait
            npc_wait(1)
        end

        -- Safety yield
        coroutine.yield()
    end
end
