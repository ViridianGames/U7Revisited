-- Activity 2: Vertical Pace
-- NPCs walk back and forth vertically (north-south)
function activity_pace_vert(npc_id)
    
    debug_npc(npc_id, "pacing vertically")
    
    -- Stand up first (in case sitting/laying down from previous activity)
    npc_frame(npc_id, 0)

    local going_south = true

    while true do
        -- Get current position
        local curr_x, curr_y, curr_z = get_npc_position(npc_id)

        -- Convert to integer tile coordinates
        curr_x = math.floor(curr_x)
        curr_y = math.floor(curr_y)
        curr_z = math.floor(curr_z)

        -- Find how far we can walk in current direction
        local dest_z = curr_z
        local step = going_south and 1 or -1

        -- Walk ahead until we hit a blocked tile (max 30 tiles to prevent infinite loop)
        local max_check = 30
        while max_check > 0 and not is_blocked(curr_x, curr_y, dest_z + step) do
            dest_z = dest_z + step
            max_check = max_check - 1
        end

        -- Walk to destination if we found somewhere to go
        if dest_z ~= curr_z then
            local request_id = request_pathfind(npc_id, curr_x, curr_y, dest_z)

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

            -- Check where we actually ended up
            local _, _, final_z = get_npc_position(npc_id)
            final_z = math.floor(final_z)

            -- Turn around after reaching the wall (or getting stuck)
            going_south = not going_south

            -- Pause when turning around
            local wait_minutes = 1 + (math.random() * 4)
            npc_wait(wait_minutes)
        else
            -- Blocked immediately, just turn around and try other direction
            going_south = not going_south
            coroutine.yield()
        end

        -- Safety yield
        coroutine.yield()
    end
end
