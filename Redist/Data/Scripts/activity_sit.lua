-- Activity 16: Sit
-- NPCs find nearest chair and sit
function activity_sit(npc_id)
    local npc_name = get_npc_name(npc_id)
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair - stand instead
        debug_print(npc_name .. " has no chair for sit activity, standing")
        play_animation(npc_id, 0, 0)  -- Frame 0 = standing
        while true do
            coroutine.yield()
        end
        return
    end

    -- STATE CHECK: Already sitting in chair?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 1.5 then
        -- Already sitting - just continue sitting
        debug_print(npc_name .. " already sitting, continuing")
        while true do
            coroutine.yield()
        end
        return
    end

    -- Walk to chair
    if distance_to(npc_id, chair) > 1.5 then
        debug_print(npc_name .. " walking to chair")
        walk_to_object(npc_id, chair)

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 1.5 do
            coroutine.yield()
        end
    end

    -- At chair but not sitting - sit down
    debug_print(npc_name .. " sitting down")
    play_animation(npc_id, 0, 26)  -- Frame 26 = sitting

    -- Stay sitting (yield forever until activity changes)
    while true do
        coroutine.yield()
    end
end
