--- Best guess: Handles NPC reactions to theft, triggering escape behavior and setting flags for NPCs (1, 3, 4).
function utility_theft_npc_reaction_0307(eventid, objectref)
    if eventid == 1 then
        utility_theft_warning_dialogue_0314(eventid, objectref) --- External call to warning function
        if random(1, 8) == 1 then
            -- Match companion dialogue "I do not join thieves" flags:
            -- Iolo 746, Dupre 747. (748 is used by Shamino for Amber, not theft.)
            if get_item_flag(6, 4) and check_npc_status(4) then
                bark(4, "@I am leaving!@")
                remove_from_party(4)
                utility_remove_npc_from_party_1087(12, 4)
                set_flag(747, true)
                set_flag(365, false)
            end
            if get_item_flag(6, 3) and check_npc_status(3) then
                bark(3, "@I am leaving!@")
                remove_from_party(3)
                utility_remove_npc_from_party_1087(12, 3)
            end
            if get_item_flag(6, 1) and check_npc_status(1) then
                bark(1, "@I am leaving!@")
                remove_from_party(1)
                utility_remove_npc_from_party_1087(12, 1)
                set_flag(746, true)
            end
        end
    end
end