-- Activity 22: Thief
-- NPCs sneak around, avoiding detection
function activity_thief(npc_id)

    debug_npc(npc_id, "thieving")
    npc_frame(npc_id, 0)

    while true do
        -- Sneak to a random location (larger radius)
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 15.0)

        if dest_x and dest_y and dest_z then
            debug_npc(npc_id, "sneaking to new location")

            local request_id = request_pathfind(npc_id, dest_x, dest_y, dest_z)

            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            start_following_path(npc_id)

            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Hide/lurk at destination (3-6 game minutes)
            local lurk_time = 3 + (math.random() * 3)
            npc_wait(lurk_time)
        else
            -- No walkable position, just lurk in place
            npc_wait(3)
        end

        -- Safety yield
        coroutine.yield()
    end
end
