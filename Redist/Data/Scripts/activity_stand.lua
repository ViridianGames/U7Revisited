-- Activity 10: Stand
-- NPCs stand motionless in place
function activity_stand(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " standing")

    -- Stand in place, yielding forever
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        coroutine.yield()
    end
end
