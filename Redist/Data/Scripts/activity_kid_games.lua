-- Activity 25: Kid Games
-- NPCs (children) play games, running around energetically
function activity_kid_games(npc_id)

    debug_npc(npc_id, "playing games")
    npc_frame(npc_id, 0)

    while true do
        -- Run to a random nearby location (energetic movement)
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 8.0)

        if dest_x and dest_y and dest_z then
            debug_npc(npc_id, "running to play")

            local request_id = request_pathfind(npc_id, dest_x, dest_y, dest_z)

            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            start_following_path(npc_id)

            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Play at location briefly (1-3 game minutes)
            local play_time = 1 + (math.random() * 2)
            npc_wait(play_time)

            -- Spin around (change facing rapidly)
            for i = 0, 3 do
                npc_frame(npc_id, i)
                wait(0.2)
            end
        else
            -- No walkable position, just fidget in place
            npc_wait(1)
        end

        -- Safety yield
        coroutine.yield()
    end
end
