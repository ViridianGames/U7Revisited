-- Function 0806: Create items at position
function func_0806(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    local2 = get_item_position(eventid)
    local3 = check_position(176, 20, local1, local2)
    local3 = table.insert(local3, check_position(176, 20, local1 + 1, local2))
    local3 = table.insert(local3, check_position(176, 20, local1 + 2, local2))
    local3 = table.insert(local3, check_position(176, 20, local1 + 3, local2))
    while local4 do
        local6 = local4
        local7 = call_0001H({968, 8021, 6, -1, 17419, 7758}, local6)
        local4 = get_next_item() -- sloop
    end
    call_0059H(7)
end