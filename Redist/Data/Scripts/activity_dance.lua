-- Activity 4: Dance
-- NPCs rotate in place, changing facing direction rhythmically
function activity_dance(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " dancing")

    -- Stand upright while dancing
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        -- Rotate through all 4 facing directions
        -- frameX controls direction: 0=south, 1=east, 2=north, 3=west
        for direction = 0, 3 do
            play_animation(npc_id, direction, 0)

            -- Quick turn interval for dancing rhythm (0.3-0.5 seconds)
            local turn_time = 0.3 + (math.random() * 0.2)
            wait(turn_time)
        end
    end
end
