-- Activity 18: Bake
-- NPCs find nearest oven and work on baking
function activity_bake(npc_id)
    local npc_name = get_npc_name(npc_id)

    -- Find nearest oven (TODO: find actual oven shape IDs)
    local oven = find_nearest_shape(npc_id, {360, 361})  -- PLACEHOLDER shape IDs

    if oven then
        -- Walk to oven if not already there
        if distance_to(npc_id, oven) > 2.0 then
            debug_print(npc_name .. " walking to oven")
            walk_to_object(npc_id, oven)

            -- Wait until we reach the oven
            while distance_to(npc_id, oven) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_print(npc_name .. " baking")

    -- Stand at oven
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        -- Work at oven for a while (4-8 seconds)
        local bake_time = 4.0 + (math.random() * 4.0)
        wait(bake_time)

        -- Occasionally turn to get ingredients or check bread
        if math.random() < 0.4 then  -- 40% chance to turn
            local direction = math.random(0, 3)
            play_animation(npc_id, direction, 0)
            wait(1.5 + (math.random() * 1.5))

            -- Turn back to oven
            play_animation(npc_id, 0, 0)
        end

        -- Safety yield to prevent instruction overrun
        coroutine.yield()
    end
end
