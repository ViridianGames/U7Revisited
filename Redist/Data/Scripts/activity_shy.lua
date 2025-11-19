-- Activity 20: Shy
-- NPCs avoid the Avatar, running away when they get close
function activity_shy(npc_id)

    debug_npc(npc_id, "being shy")
    npc_frame(npc_id, 0)

    while true do
        -- Check if Avatar is nearby
        local avatar_id = 0  -- Avatar is typically NPC ID 0
        local avatar_pos = get_npc_position(avatar_id)
        local npc_pos = get_npc_position(npc_id)

        if avatar_pos and npc_pos then
            local dx = avatar_pos.x - npc_pos.x
            local dz = avatar_pos.z - npc_pos.z
            local distance = math.sqrt(dx * dx + dz * dz)

            -- If Avatar is within 8 tiles, run away
            if distance < 8.0 then
                debug_npc(npc_id, "running from Avatar")

                -- Calculate direction away from Avatar
                local away_x = npc_pos.x - (dx * 0.5)
                local away_z = npc_pos.z - (dz * 0.5)

                -- Try to find a walkable position in that direction
                local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 5.0)

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
            else
                -- Avatar far away, just stand nervously
                npc_wait(2)
            end
        else
            -- Can't find Avatar, just wait
            npc_wait(2)
        end

        -- Safety yield
        coroutine.yield()
    end
end
