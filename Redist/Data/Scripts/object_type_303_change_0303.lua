--- Best guess: Handles item type changes and actions based on event IDs, setting an item type (303) or triggering actions for a quest item (936).
function object_unknown_0303(eventid, objectref)
    if eventid == 2 then
        set_item_shape(303, objectref)
        return
    elseif eventid == 1 then
        flash_mouse(0)
    end
    utility_event_0819(936, objectref)
    return
end