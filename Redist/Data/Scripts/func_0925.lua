-- Function 0925: Adjust item weight
function func_0925(eventid, itemref)
    local local0, local1

    local1 = get_item_weight(-356, itemref)
    if local1 <= 1 then
        delete_item(itemref)
    else
        local1 = local1 - 1
        local2 = set_item_weight(local1, itemref)
    end
    return
end