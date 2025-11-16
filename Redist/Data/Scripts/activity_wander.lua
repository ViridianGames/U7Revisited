-- Activity 12: Wander
-- NPCs wander randomly within a small radius
function activity_wander(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " wandering")

    -- Get current position as anchor point
    local anchor_x, anchor_y, anchor_z = get_npc_position(npc_id)

    while true do
        -- Pick a random destination within 10 tiles of anchor
        local offset_x = (math.random() * 20.0) - 10.0
        local offset_z = (math.random() * 20.0) - 10.0
        local dest_x = anchor_x + offset_x
        local dest_z = anchor_z + offset_z

        -- Walk to random destination
        walk_to_position(npc_id, dest_x, anchor_y, dest_z)

        -- Wait a bit at destination (random 2-5 seconds worth of frames)
        local wait_frames = math.random(120, 300)  -- Assuming ~60 fps
        for i = 1, wait_frames do
            coroutine.yield()
        end
    end
end
