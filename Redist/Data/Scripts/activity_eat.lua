-- Activity 5: Eat
-- NPCs find nearest chair (at table) and sit to eat
function activity_eat(npc_id)
    local npc_name = get_npc_name(npc_id)
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair/table nearby - just stand
        debug_print(npc_name .. " has no table for eat activity, standing")
        play_animation(npc_id, 0, 0)  -- Frame 0 = standing
        while true do
            coroutine.yield()
        end
        return
    end

    -- STATE CHECK: Already sitting at table?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 2.0 then
        -- Already sitting and eating - stay here
        debug_print(npc_name .. " already eating, continuing")
        while true do
            coroutine.yield()
        end
        return
    end

    -- Walk to chair/table if not already there
    if distance_to(npc_id, chair) > 2.0 then
        debug_print(npc_name .. " walking to table")
        walk_to_object(npc_id, chair)

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 2.0 do
            coroutine.yield()
        end
    end

    -- Sit down at table to eat
    debug_print(npc_name .. " sitting down to eat")
    play_animation(npc_id, 0, 26)  -- Frame 26 = sitting

    -- Stay eating (yield forever until activity changes)
    while true do
        coroutine.yield()
    end
end
