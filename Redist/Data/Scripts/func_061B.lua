-- Handles the generator in Dungeon Despise, triggering effects and creating items when interacted with during event 2.
function func_061B(eventid, itemref)
    local local0, local1

    if eventid == 2 then
        external_0806(itemref, 234) -- Unmapped intrinsic
        local0 = get_item_quality(617)
        set_schedule(617, 15)
        local1 = add_item(25, 617, {17493, 7715})
    end
    return
end