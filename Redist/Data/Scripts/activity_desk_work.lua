-- Activity 30: Desk Work
-- NPCs sit at desk and work
function activity_desk_work(npc_id)
    
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair/desk nearby - just stand
        debug_npc(npc_id, "has no desk for desk work activity, standing")
        npc_frame(npc_id, 0)  -- Frame 0 = standing

        while true do
            coroutine.yield()
        end
        return
    end

    -- STATE CHECK: Already sitting at desk?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 2.0 then
        -- Already sitting and working - stay here
        debug_npc(npc_id, "already working at desk, continuing")
        while true do
            coroutine.yield()
        end
        return
    end

    -- Walk to desk chair if not already there
    if distance_to(npc_id, chair) > 2.0 then
        debug_npc(npc_id, "walking to desk")
        walk_to_object(npc_id, chair)

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 2.0 do
            coroutine.yield()
        end
    end

    -- Sit down at desk
    debug_npc(npc_id, "sitting down at desk")
    npc_frame(npc_id, 26)  -- Frame 26 = sitting

    -- Stay working (yield forever until activity changes)
    while true do
        coroutine.yield()
    end
end
