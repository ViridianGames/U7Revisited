-- Activity 12: Wander
-- NPCs wander randomly within a small radius
function activity_wander(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " wandering")

    while true do
        -- Try to find a random walkable destination within 10 tiles
        local dest_x, dest_y, dest_z = nil, nil, nil
        local attempts = 0

        while not dest_x and attempts < 10 do
            dest_x, dest_y, dest_z = find_random_walkable(npc_id, 10.0)
            if not dest_x then
                attempts = attempts + 1
                coroutine.yield()  -- Yield between attempts to avoid blocking
            end
        end

        if dest_x and dest_y and dest_z then
            -- Found a valid destination - walk to it
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Wait a bit at destination (random 2-5 seconds)
            local wait_time = 2.0 + (math.random() * 3.0)
            wait(wait_time)
        else
            -- Couldn't find a walkable position after 10 attempts - just stand still
            debug_print(npc_name .. " couldn't find walkable position, standing")
            wait(2.0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
