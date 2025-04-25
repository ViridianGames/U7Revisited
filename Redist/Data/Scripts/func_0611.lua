-- Transforms an item's type based on its current type, likely for crafting or quest progression.
function func_0611(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = get_item_type(itemref)
    if local0 == 515 then
        local1 = 870
        local2 = 7
    else
        local1 = 515
        local2 = -7
    end

    local3 = get_item_data(itemref)
    set_item_type(itemref, local1, local3[2] + local2)
    if remove_item(itemref) then
        set_item_owner(local3, itemref)
        local4 = true
    end

    return
end