-- Function 01B3: Item type switching
function func_01B3(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    -- Eventid == 1 or 2: Set item type
    if eventid == 1 or eventid == 2 then
        _SetItemType(481, itemref)
        calli_005C(itemref)
    end

    -- Eventid == 7: Update position
    if eventid == 7 then
        _SetItemType(481, itemref)
        local0 = call_0827H(itemref, -356)
        local1 = callis_0001({17505, 17514, 8449, local0, 7769}, -356)
    end

    return
end