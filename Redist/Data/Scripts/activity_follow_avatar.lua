-- Activity 31: Follow Avatar
-- NPCs follow the Avatar (party members, companions)
function activity_follow_avatar(npc_id)

    debug_npc(npc_id, "following Avatar")
    npc_frame(npc_id, 0)

    while true do
        -- Get Avatar position (Avatar is typically NPC ID 0)
        local avatar_id = 0
        local avatar_pos = get_npc_position(avatar_id)
        local npc_pos = get_npc_position(npc_id)

        if avatar_pos and npc_pos then
            local dx = avatar_pos.x - npc_pos.x
            local dz = avatar_pos.z - npc_pos.z
            local distance = math.sqrt(dx * dx + dz * dz)

            -- If Avatar is more than 4 tiles away, follow
            if distance > 4.0 then
                debug_npc(npc_id, "catching up to Avatar")

                -- Pathfind to Avatar's position
                local request_id = request_pathfind(npc_id, avatar_pos.x, avatar_pos.y, avatar_pos.z)

                while not is_path_ready(request_id) do
                    coroutine.yield()
                end

                start_following_path(npc_id)

                -- Follow for a bit, but check distance regularly
                -- (don't wait for full path completion)
                local follow_ticks = 0
                while follow_ticks < 30 do
                    coroutine.yield()
                    follow_ticks = follow_ticks + 1

                    -- Recheck distance
                    npc_pos = get_npc_position(npc_id)
                    if npc_pos then
                        dx = avatar_pos.x - npc_pos.x
                        dz = avatar_pos.z - npc_pos.z
                        distance = math.sqrt(dx * dx + dz * dz)

                        -- If close enough, stop following
                        if distance < 3.0 then
                            break
                        end
                    end
                end
            else
                -- Close enough to Avatar, just stand nearby
                npc_wait(1)
            end
        else
            -- Can't find Avatar, just wait
            npc_wait(2)
        end

        -- Safety yield
        coroutine.yield()
    end
end
