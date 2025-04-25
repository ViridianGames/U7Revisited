-- Function 0888: Process party items
function func_0888(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    local1 = false
    local2 = false
    local3 = false
    local4 = check_position(8, 5, -1, itemref)
    while local7 do
        local8 = _Random2(20, 15)
        local9 = call_0061H(local7, 2, local8, 0, _GetNPCProperty(local7))
        local10 = call_003CH(local7)
        if local10 == 2 then
            local1 = true
        elseif local10 == 3 then
            local2 = true
        elseif local10 == 0 then
            local3 = true
        end
        local7 = get_next_item() -- sloop
    end
    local4 = check_position(8, 80, -1, itemref)
    if local1 or local2 then
        while local7 do
            local13 = _GetItemType(local7)
            if local13 ~= 721 and local13 ~= 989 then
                call_001DH(0, local7)
            end
            local7 = get_next_item() -- sloop
        end
    elseif local3 then
        while local7 do
            local13 = _GetItemType(local7)
            if local13 ~= 721 and local13 ~= 989 then
                call_003DH(2, local7)
                call_001DH(0, local7)
            end
            local7 = get_next_item() -- sloop
        end
    end
    local16 = check_position(0, 5, 270, itemref)
    while local19 do
        local14 = get_item_position(local19)
        if local14[1] == 2809 and local14[2] == 319 and local14[3] == 0 then
            delete_item(local19)
        end
        local19 = get_next_item() -- sloop
    end
    return
end