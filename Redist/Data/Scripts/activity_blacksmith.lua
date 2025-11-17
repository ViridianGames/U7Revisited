-- Activity 13: Blacksmith
-- NPCs find nearest anvil and work at it
function activity_blacksmith(npc_id)
    local npc_name = get_npc_name(npc_id)

    -- Find nearest anvil (TODO: find actual anvil shape IDs)
    local anvil = find_nearest_shape(npc_id, {991, 992})  -- PLACEHOLDER shape IDs

    if anvil then
        -- Walk to anvil if not already there
        if distance_to(npc_id, anvil) > 2.0 then
            debug_print(npc_name .. " walking to anvil")
            walk_to_object(npc_id, anvil)

            -- Wait until we reach the anvil
            while distance_to(npc_id, anvil) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_print(npc_name .. " working as blacksmith")

    -- Stand at anvil working
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        -- Work at anvil for a while (3-7 seconds)
        local work_time = 3.0 + (math.random() * 4.0)
        wait(work_time)

        -- Occasionally turn to get materials or check work
        if math.random() < 0.3 then  -- 30% chance to turn
            local direction = math.random(0, 3)
            play_animation(npc_id, direction, 0)
            wait(1.0 + (math.random() * 1.0))

            -- Turn back to anvil
            play_animation(npc_id, 0, 0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
