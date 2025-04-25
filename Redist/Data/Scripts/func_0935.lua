-- Function 0935: Find NPC with lowest quantity
function func_0935(eventid, itemref)
    local local0, local1, local2, local3

    local2 = itemref[1]
    while itemref do
        local3 = itemref
        if get_item_quantity(local3, local0) < get_item_quantity(local2, local0) then
            local2 = local3
        end
        itemref = get_next_member() -- sloop
    end
    set_return(local2)
end