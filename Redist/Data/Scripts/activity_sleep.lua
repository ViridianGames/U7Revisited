-- Activity 14: Sleep
-- NPCs find nearest bed and sleep until the schedule block changes
function activity_sleep(npc_id)
    local bed = find_nearest_bed(npc_id)

    if not bed then
        -- No bed nearby - just stand idle
        debug_npc(npc_id, "has no bed for sleep activity")
        coroutine.yield()
        return
    end

    -- Remember the schedule block when we started sleeping
    local sleep_schedule_block = get_schedule_time()

    -- Walk to bed if not already there
    if distance_to(npc_id, bed) > 2.0 then
        debug_npc(npc_id, "walking to bed")
        walk_to_object(npc_id, bed)

        -- Wait until we reach the bed
        while distance_to(npc_id, bed) > 2.0 do
            coroutine.yield()
        end
    end

    -- At bed but not sleeping - lie down
    debug_npc(npc_id, "lying down in bed")
    npc_frame(npc_id, 29)  -- Frame 29 = lying down

    -- Sleep forever (schedule system will stop this script when activity changes)
    while true do
        coroutine.yield()
    end
end
