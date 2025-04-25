-- Handles generator interaction, likely in a dungeon, triggering effects and creating items during event 2.
function func_061D(eventid, itemref)
    local local0, local1

    if eventid == 2 then
        local0 = get_item_data(itemref)
        external_0806(itemref, 238) -- Unmapped intrinsic
        local1 = add_item(25, 617, {17493, 7715})
    end
    return
end