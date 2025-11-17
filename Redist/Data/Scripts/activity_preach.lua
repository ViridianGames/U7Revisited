-- Activity 28: Preach
-- NPCs find nearest pulpit and stand preaching, turning to address congregation
function activity_preach(npc_id)
    local npc_name = get_npc_name(npc_id)

    -- Find nearest pulpit (TODO: find actual pulpit shape IDs)
    local pulpit = find_nearest_shape(npc_id, {999})  -- PLACEHOLDER shape ID

    if pulpit then
        -- Walk to pulpit if not already there
        if distance_to(npc_id, pulpit) > 2.0 then
            debug_print(npc_name .. " walking to pulpit")
            walk_to_object(npc_id, pulpit)

            -- Wait until we reach the pulpit
            while distance_to(npc_id, pulpit) > 2.0 do
                coroutine.yield()
            end
        end
    end

    debug_print(npc_name .. " preaching")

    -- Stand at pulpit
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        -- Face forward for a while (5-10 seconds)
        play_animation(npc_id, 0, 0)
        local speak_time = 5.0 + (math.random() * 5.0)
        wait(speak_time)

        -- Turn to face congregation on left side
        play_animation(npc_id, 3, 0)
        wait(2.0 + (math.random() * 2.0))

        -- Turn to face congregation on right side
        play_animation(npc_id, 1, 0)
        wait(2.0 + (math.random() * 2.0))
    end
end
