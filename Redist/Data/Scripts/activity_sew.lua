-- Activity 19: Sew
-- NPCs sit and work on sewing
function activity_sew(npc_id)
    
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair nearby - stand and work instead
        debug_npc(npc_id, "has no chair for sewing, standing")
        npc_frame(npc_id, 0)  -- Frame 0 = standing

        while true do
            coroutine.yield()
        end
        return
    end

    -- STATE CHECK: Already sitting and sewing?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 2.0 then
        -- Already sitting and sewing - stay here
        debug_npc(npc_id, "already sewing, continuing")
        while true do
            coroutine.yield()
        end
        return
    end

    -- Walk to chair if not already there
    if distance_to(npc_id, chair) > 2.0 then
        debug_npc(npc_id, "walking to sewing chair")
        walk_to_object(npc_id, chair)

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 2.0 do
            coroutine.yield()
        end
    end

    -- Sit down to sew
    debug_npc(npc_id, "sitting down to sew")
    npc_frame(npc_id, 26)  -- Frame 26 = sitting

    -- Stay sewing (yield forever until activity changes)
    while true do
        coroutine.yield()
    end
end
