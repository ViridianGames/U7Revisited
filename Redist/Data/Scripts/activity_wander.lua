-- Activity 12: Wander
-- NPCs wander randomly within a small radius
function activity_wander(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " wandering")

    while true do
        -- Find a random walkable destination within 10 tiles
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 10.0)

        if dest_x and dest_y and dest_z then
            -- Found a valid destination - walk to it
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Wait a bit at destination (random 2-5 seconds)
            local wait_time = 2.0 + (math.random() * 3.0)
            wait(wait_time)
        else
            -- Couldn't find a walkable position - just stand still for a bit
            debug_print(npc_name .. " couldn't find walkable position, standing")
            wait(1.0)
        end
    end
end
