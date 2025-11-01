--- Best guess: Handles NPC reactions to theft, triggering escape behavior and setting flags for NPCs (1, 3, 4).
function utility_unknown_0307(eventid, objectref)
    if eventid == 1 then
        utility_unknown_0314(objectref) --- External call to warning function
        if random(1, 8) == 1 then
            if get_item_flag(6, 4) and check_npc_status(4) then
                bark(4, "@I am leaving!@")
                remove_from_party(4) --- Guess: Sets NPC behavior
                utility_unknown_1087(12, 4) --- Guess: Updates object state
                set_flag(746, true)
            end
            if get_item_flag(6, 3) and check_npc_status(3) then
                bark(3, "@I am leaving!@")
                set_flag(747, true)
                remove_from_party(3) --- Guess: Sets NPC behavior
                utility_unknown_1087(12, 3) --- Guess: Updates object state
            end
            if get_item_flag(6, 1) and check_npc_status(1) then
                bark(1, "@I am leaving!@")
                set_flag(748, true)
                remove_from_party(1) --- Guess: Sets NPC behavior
                utility_unknown_1087(12, 1) --- Guess: Updates object state
            end
        end
    end
end