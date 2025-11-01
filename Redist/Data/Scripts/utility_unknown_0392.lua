--- Best guess: Updates NPC state, likely a helper function for other scripts (e.g., func_0669, func_0677), setting NPC states and quest flags.
function utility_unknown_0392(eventid, objectref)
    if eventid == 2 then
        update_npc_state(12, objectref) --- Guess: Updates NPC state
        clear_item_flag(15, objectref) --- Guess: Sets quest flag
    end
end