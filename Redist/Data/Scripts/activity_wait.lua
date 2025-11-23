-- Activity 15: Wait
-- NPCs stand and wait in place
function activity_wait(npc_id)
    
    debug_npc(npc_id, "waiting")

    -- Stand in place, yielding forever
    npc_frame(npc_id, 0)  -- Frame 0 = standing

    while true do
        coroutine.yield()
    end
end
