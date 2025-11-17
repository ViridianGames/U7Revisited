-- Activity 7: Tend Shop
-- NPCs find nearest counter and stand behind it, occasionally turning
function activity_tend_shop(npc_id)
    local npc_name = get_npc_name(npc_id)

    -- Find nearest counter (TODO: find actual counter/shop table shape IDs)
    local counter = find_nearest_shape(npc_id, {890, 891})  -- PLACEHOLDER counter shape IDs

    if counter then
        -- Walk to counter if not already there
        if distance_to(npc_id, counter) > 2.0 then
            debug_print(npc_name .. " walking to shop counter")
            walk_to_object(npc_id, counter)

            -- Wait until we reach the counter
            while distance_to(npc_id, counter) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_print(npc_name .. " tending shop")

    -- Stand in place at shop counter
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        -- Stand facing one direction for a while (5-10 seconds)
        local wait_time = 5.0 + (math.random() * 5.0)
        wait(wait_time)

        -- Occasionally turn to face a different direction
        -- frameX controls facing direction (0-3 for different orientations)
        local direction = math.random(0, 3)
        play_animation(npc_id, direction, 0)
    end
end
