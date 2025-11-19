-- Activity 3: Talk
-- NPCs stand in place and occasionally turn (as if conversing)
function activity_talk(npc_id)

    debug_npc(npc_id, "talking")
    npc_frame(npc_id, 0)

    while true do
        -- Stand facing one direction for a while (3-8 game minutes)
        local talk_time = 3 + (math.random() * 5)
        npc_wait(talk_time)

        -- Occasionally turn to face a different direction
        -- (simulating talking to different people or looking around)
        local direction = math.random(0, 3)
        npc_frame(npc_id, direction)

        -- Safety yield
        coroutine.yield()
    end
end
