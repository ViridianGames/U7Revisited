--- Best guess: Handles item type changes and actions based on event IDs, setting an item type (303) or triggering actions for a quest item (936).
function func_012F(eventid, itemref)
    if eventid == 2 then
        unknown_000DH(303, itemref)
        return
    elseif eventid == 1 then
        unknown_006AH(0)
    end
    unknown_0833H(936, itemref)
    return
end