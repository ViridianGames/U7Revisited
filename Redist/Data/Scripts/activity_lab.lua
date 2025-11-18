-- Activity 21: Lab
-- NPCs find nearest lab equipment and work on experiments
function activity_lab(npc_id)
    

    -- Find nearest lab equipment (TODO: find actual lab equipment shape IDs)
    local equipment = find_nearest_shape(npc_id, {700, 701, 702})  -- PLACEHOLDER shape IDs (beakers, burners, etc)

    if equipment then
        -- Walk to equipment if not already there
        if distance_to(npc_id, equipment) > 2.0 then
            debug_npc(npc_id, "walking to lab equipment")
            walk_to_object(npc_id, equipment)

            -- Wait until we reach the equipment
            while distance_to(npc_id, equipment) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_npc(npc_id, "working in lab")

    -- Stand at lab equipment
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        -- Work at lab equipment for a while (5-10 seconds)
        local work_time = 5.0 + (math.random() * 5.0)
        wait(work_time)

        -- Occasionally turn to check other equipment or get supplies
        if math.random() < 0.5 then  -- 50% chance to turn
            local direction = math.random(0, 3)
            
            wait(2.0 + (math.random() * 2.0))

            -- Turn back to main equipment
            npc_frame(npc_id, 0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
