-- Activity 12: Wander
-- NPCs wander randomly within a small radius
function activity_wander(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " wandering")

    while true do
        -- Try to find a random walkable destination within 10 tiles
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 10.0)

        if dest_x and dest_y and dest_z then
            -- Found a valid destination - walk to it
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Wait until path completes
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
