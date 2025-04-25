-- Function 0926: Transfer item to party member
function func_0926(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local1 = false
    local2 = _GetItemType(itemref)
    local3 = _GetItemFrame(itemref)
    local4 = _GetItemQuality(itemref)
    local5 = _GetPartyMembers()
    while local5 do
        local6 = local5
        local9 = _GetContainerItems(local3, local4, local2, local6)
        while local9 do
            local10 = local9
            if local10 == itemref then
                local1 = local6
                local11 = set_item_owner(local1)
                local11 = remove_item(itemref)
            end
            local9 = get_next_item() -- sloop
        end
        local5 = get_next_party_member() -- sloop
    end
    if local1 == false then
        local1 = get_item_position(itemref)
        local11 = set_item_position(local1)
        local11 = remove_item(itemref)
    end
    return
end