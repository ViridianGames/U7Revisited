-- Activity 0: Combat
-- NPCs engage in combat (handled by C++ combat system, this is a placeholder)
function activity_combat(npc_id)

    debug_npc(npc_id, "in combat mode")

    -- Combat is primarily handled by the C++ combat system
    -- This script just keeps the NPC in combat-ready state
    npc_frame(npc_id, 0)

    while true do
        -- The actual combat logic (target selection, attacking, movement)
        -- is handled in C++ (U7Object::Attack, etc.)
        -- This just yields to allow the combat system to take control
        coroutine.yield()
    end
end
