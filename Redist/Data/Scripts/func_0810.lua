-- Function 0810: Cube puzzle floor manipulation
function func_0810(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if local1 == 0 then
        local1 = 368
        local2 = 8
    else
        local1 = 369
        local2 = 5
    end
    local3 = get_item_position(itemref)
    local3 = table.insert(local3, _GetItemQuality(itemref))
    local3 = table.insert(local3, 6)
    local4 = check_position(16, 80, 275, local3)
    local5 = 0
    while local6 do
        local8 = local6
        local5 = local5 + 1
        local3 = get_item_position(local8)
        local9 = check_position(0, 1, local1, local3)
        if eventid == 1 then
            if local9 then
                local10 = call_0025H(local9)
                local10 = call_0026H(-358)
                call_000FH(10)
            end
        else
            if local9 == 0 then
                local11 = call_0024H(local1)
                _SetItemFrame(local2, local11)
                local10 = call_0026H(local3)
                local10 = call_0025H(local9)
                local10 = call_0026H(-358)
                call_000FH(83)
            end
        end
        local6 = get_next_item() -- sloop
    end
end