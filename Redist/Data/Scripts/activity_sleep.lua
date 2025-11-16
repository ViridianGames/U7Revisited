-- Activity 14: Sleep
-- NPCs find nearest bed and sleep until 6am
function activity_sleep(npc_id)
    local npc_name = get_npc_name(npc_id)
    local bed = find_nearest_bed(npc_id)

    if not bed then
        -- No bed nearby - just stand idle
        debug_print(npc_name .. " has no bed for sleep activity")
        coroutine.yield()
        return
    end

    -- STATE CHECK: Already sleeping in bed?
    if is_sleeping(npc_id) and distance_to(npc_id, bed) < 2.0 then
        -- Already in bed sleeping - just continue sleeping
        debug_print(npc_name .. " already sleeping, continuing")
        -- Wait until 6am
        while get_current_hour() < 6 or get_current_hour() >= 22 do
            coroutine.yield()
        end
        return
    end

    -- Walk to bed if not already there
    if distance_to(npc_id, bed) > 2.0 then
        debug_print(npc_name .. " walking to bed")
        walk_to_object(npc_id, bed)

        -- Wait until we reach the bed
        while distance_to(npc_id, bed) > 2.0 do
            coroutine.yield()
        end
    end

    -- At bed but not sleeping - lie down
    debug_print(npc_name .. " lying down in bed")
    play_animation(npc_id, 0, 16)  -- Frame 16 = lying down

    -- Sleep until 6am
    while get_current_hour() < 6 or get_current_hour() >= 22 do
        coroutine.yield()
    end

    -- Wake up - stand up animation
    debug_print(npc_name .. " waking up")
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing
end
