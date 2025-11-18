-- Activity 1: Horizontal Pace
-- NPCs walk back and forth horizontally (east-west)
function activity_pace_horz(npc_id)
    
    debug_npc(npc_id, "pacing horizontally")
    
    -- Stand up first (in case sitting/laying down from previous activity)
    npc_frame(npc_id, 0)

    local going_east = true

    while true do
        -- Get current position
        local curr_x, curr_y, curr_z = get_npc_position(npc_id)

        -- Convert to integer tile coordinates
        curr_x = math.floor(curr_x)
        curr_y = math.floor(curr_y)
        curr_z = math.floor(curr_z)

        -- Find how far we can walk in current direction
        local dest_x = curr_x
        local step = going_east and 1 or -1

        -- Walk ahead until we hit a blocked tile (max 30 tiles to prevent infinite loop)
        local max_check = 30
        while max_check > 0 and not is_blocked(dest_x + step, curr_y, curr_z) do
            dest_x = dest_x + step
            max_check = max_check - 1
        end

        -- Walk to destination if we found somewhere to go
        if dest_x ~= curr_x then
            -- Step 1: Request pathfind
            local request_id = request_pathfind(npc_id, dest_x, curr_y, curr_z)

            -- Step 2: Wait for path to be computed
            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            -- Step 3: Start following the path
            start_following_path(npc_id)

            -- Wait until movement completes
            while not wait_move_end(npc_id) do
                coroutine.yield()
            end

            -- Check where we actually ended up
            local final_x, _, _ = get_npc_position(npc_id)
            final_x = math.floor(final_x)

            -- Turn around after reaching the wall (or getting stuck)
            going_east = not going_east

            -- Pause when turning around
            local wait_minutes = 1 + (math.random() * 4)
            npc_wait(wait_minutes)
        else
            -- Blocked immediately, just turn around and try other direction
            going_east = not going_east
            coroutine.yield()
        end

        -- Safety yield
        coroutine.yield()
    end
end
