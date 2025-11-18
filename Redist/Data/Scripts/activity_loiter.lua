-- Activity 11: Loiter
-- NPCs move around a small area, standing/sitting around casually
function activity_loiter(npc_id)
    debug_npc(npc_id, "loitering")
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Stand still for a while (0.5 to 1 game minute)
        npc_frame(npc_id, 0)  -- Frame 0 = standing
        local stand_minutes = 5 + (math.random() * 5)  -- 0.5-1.0 game minutes
        npc_wait(stand_minutes)

        -- Move to a nearby spot (within 3-5 tiles) - 80% of the time
        if math.random() < 0.8 then  -- 80% chance to move
            local radius = 3.0 + (math.random() * 2.0)  -- Random radius 3-5 tiles
            local dest_x, dest_y, dest_z = find_random_walkable(npc_id, radius)

            if dest_x and dest_y and dest_z then
                -- Found a valid destination - walk to it
                walk_to_position(npc_id, dest_x, dest_y, dest_z)

                -- Wait until path completes
                while not wait_move_end(npc_id) do
                    coroutine.yield()
                end
            end
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
