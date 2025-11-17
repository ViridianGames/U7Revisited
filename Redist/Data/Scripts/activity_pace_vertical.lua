-- Activity 2: Vertical Pace
-- NPCs walk back and forth vertically (north-south)
function activity_pace_vertical(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " pacing vertically")

    -- Get starting position
    local start_x, start_y, start_z = get_npc_position(npc_id)

    -- Pace 5 tiles in each direction from starting point
    local pace_distance = 5.0
    local going_south = true

    while true do
        local dest_x, dest_z

        if going_south then
            -- Walk south (positive Z)
            dest_x = start_x
            dest_z = start_z + pace_distance
        else
            -- Walk north (negative Z)
            dest_x = start_x
            dest_z = start_z - pace_distance
        end

        -- Walk to destination
        walk_to_position(npc_id, dest_x, start_y, dest_z)

        -- Wait until we reach destination
        while true do
            local curr_x, curr_y, curr_z = get_npc_position(npc_id)
            local distance = math.sqrt((curr_x - dest_x)^2 + (curr_z - dest_z)^2)

            if distance < 1.0 then
                break
            end

            coroutine.yield()
        end

        -- Pause briefly at each end (0.5-1 second)
        wait(0.5 + (math.random() * 0.5))

        -- Reverse direction
        going_south = not going_south
    end
end
