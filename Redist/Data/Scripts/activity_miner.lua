-- Activity 8: Miner
-- NPCs perform mining animation (striking with pickaxe)
function activity_miner(npc_id)

    debug_npc(npc_id, "mining")

    while true do
        -- Stand in place
        npc_frame(npc_id, 0)

        -- Wait a bit before next mining action (2-4 game minutes)
        local wait_time = 2 + (math.random() * 2)
        npc_wait(wait_time)

        -- TODO: Play mining animation when animation system is implemented
        -- For now just cycle through frames to simulate work
        for i = 0, 3 do
            npc_frame(npc_id, i)
            wait(0.3)  -- Brief pause between frames
        end

        -- Safety yield
        coroutine.yield()
    end
end
