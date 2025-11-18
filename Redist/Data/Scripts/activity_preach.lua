-- Activity 28: Preach
-- NPCs find nearest pulpit and stand preaching, turning to address congregation
function activity_preach(npc_id)

    -- Find nearest pulpit (TODO: find actual pulpit shape IDs)
    local pulpit = find_nearest_shape(npc_id, {999})  -- PLACEHOLDER shape ID

    if pulpit then
        -- Walk to pulpit if not already there
        if distance_to(npc_id, pulpit) > 2.0 then
            debug_npc(npc_id, "walking to pulpit")
            walk_to_object(npc_id, pulpit)

            -- Wait until we reach the pulpit
            while distance_to(npc_id, pulpit) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "preaching")

    -- Stand at pulpit
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Face forward for a while (5-10 seconds)
        npc_frame(npc_id, 0)
        local speak_time = 5.0 + (math.random() * 5.0)
        wait(speak_time)

        -- Turn to face congregation on left side
        
        wait(2.0 + (math.random() * 2.0))

        -- Turn to face congregation on right side
        
        wait(2.0 + (math.random() * 2.0))

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
