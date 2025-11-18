-- Activity 10: Stand
-- NPCs stand motionless in place
function activity_stand(npc_id)
    
    debug_npc(npc_id, "standing")

    -- Stand in place, yielding forever
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        coroutine.yield()
    end
end
