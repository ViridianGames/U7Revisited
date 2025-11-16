-- Activity 11: Loiter
-- NPCs stand around doing nothing in particular
function activity_loiter(npc_id)
    local npc_name = get_npc_name(npc_id)
    debug_print(npc_name .. " loitering")

    -- Just stand in place, yielding forever
    play_animation(npc_id, 0, 0)  -- Frame 0 = standing

    while true do
        coroutine.yield()
    end
end
