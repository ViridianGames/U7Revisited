--- Best guess: Checks multiple flags (544, 555, 548, 554, 549) and triggers effects on NPCs (167, 177) based on flag conditions when event ID 3 is received.
function utility_event_0454(eventid, objectref)
    if eventid == 3 then
        if get_flag(FLAG_MET_FERIDWYN) and get_flag(FLAG_MET_TOBIAS) and get_flag(FLAG_MET_GARRITT) and get_flag(FLAG_MET_CAMILLE) and get_flag(FLAG_MET_MORFIN) then
            set_flag(FLAG_PAWS_FRAME_READY, true)
        end
        if get_flag(FLAG_PAWS_FRAME_READY) and not get_flag(FLAG_TOBIAS_FRAMED) then
            utility_unknown_1087(3, get_npc_name(NPC_FERIDWYN))
        end
        if get_flag(FLAG_FERIDWYN_ACCUSED_TOBIAS) and not get_flag(FLAG_CAMILLE_BEGGED_CLEAR_TOBIAS) then
            utility_unknown_1087(3, get_npc_name(NPC_CAMILLE))
        end
    end
    return
end