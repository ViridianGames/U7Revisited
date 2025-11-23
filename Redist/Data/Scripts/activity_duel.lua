-- Activity 27: Duel
-- NPCs engage in formal combat/sparring (practice fighting)
function activity_duel(npc_id)

    debug_npc(npc_id, "dueling")
    npc_frame(npc_id, 0)

    while true do
        -- Stand in combat stance for a while
        local stance_time = 2 + (math.random() * 3)
        npc_wait(stance_time)

        -- TODO: Play attack animation when animation system is implemented
        -- For now, cycle through frames to simulate combat moves
        for i = 0, 3 do
            npc_frame(npc_id, i)
            wait(0.4)
        end

        -- Brief pause between strikes
        npc_wait(1)

        -- Safety yield
        coroutine.yield()
    end
end
