-- Activity 29: Patrol
-- NPCs patrol around an area, walking to random positions
function activity_patrol(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " patrolling")

    while true do
        -- Find a random patrol point within 12 tiles
        local dest_x, dest_y, dest_z = find_random_walkable(npc_id, 12.0)

        if dest_x and dest_y and dest_z then
            -- Walk to patrol point
            walk_to_position(npc_id, dest_x, dest_y, dest_z)

            -- Pause at patrol point, looking around (2-4 seconds)
            local pause_time = 2.0 + (math.random() * 2.0)
            wait(pause_time)

            -- Look in different directions while at patrol point
            for i = 1, 2 do
                local direction = math.random(0, 3)
                play_animation(npc_id, direction, 0)
                wait(1.0)
            end
        else
            -- Couldn't find a patrol point - just stand and look around
            debug_print(npc_name .. " couldn't find patrol point, standing")
            local direction = math.random(0, 3)
            play_animation(npc_id, direction, 0)
            wait(2.0)
        end
    end
end
