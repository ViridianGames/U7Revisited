--- Paws venom quest: when all key townsfolk have been met, mark the framing
--- beat ready and put Feridwyn on Talk so he approaches the Avatar.
--- Also puts Camille on Talk after Feridwyn has accused Tobias.
---
--- Called from the Paws usecode egg (utility_event_0454) and from each NPC's
--- first-meet so we do not depend solely on a one-shot egg.

function utility_paws_check_frame_ready()
    local met = {
        feridwyn = get_flag(FLAG_MET_FERIDWYN),
        tobias   = get_flag(FLAG_MET_TOBIAS),
        garritt  = get_flag(FLAG_MET_GARRITT),
        camille  = get_flag(FLAG_MET_CAMILLE),
        morfin   = get_flag(FLAG_MET_MORFIN),
    }

    local missing = {}
    for name, ok in pairs(met) do
        if not ok then
            table.insert(missing, name)
        end
    end

    if #missing > 0 then
        debug_print("paws_frame: waiting for MET_* — missing: " .. table.concat(missing, ", "))
        return false
    end

    if not get_flag(FLAG_PAWS_FRAME_READY) then
        set_flag(FLAG_PAWS_FRAME_READY, true)
        debug_print("paws_frame: FLAG_PAWS_FRAME_READY set")
    end

    if get_flag(FLAG_PAWS_FRAME_READY) and not get_flag(FLAG_TOBIAS_FRAMED) then
        debug_print("paws_frame: putting Feridwyn on Talk (activity 3)")
        utility_unknown_1087(3, NPC_FERIDWYN)
    end

    if get_flag(FLAG_FERIDWYN_ACCUSED_TOBIAS) and not get_flag(FLAG_CAMILLE_BEGGED_CLEAR_TOBIAS) then
        debug_print("paws_frame: putting Camille on Talk")
        utility_unknown_1087(3, NPC_CAMILLE)
    end

    return true
end
