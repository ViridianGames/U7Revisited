-- Activity 24: Special
-- Special/custom NPC behavior (placeholder - can be overridden per-NPC)
function activity_special(npc_id)

    debug_npc(npc_id, "special activity")

    -- This is a placeholder for NPCs with unique behaviors
    -- Individual NPCs can override this with custom scripts
    -- For now, just stand in place
    npc_frame(npc_id, 0)

    while true do
        coroutine.yield()
    end
end
