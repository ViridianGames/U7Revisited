-- Function 0816: Manipulate door and items
function func_0816(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30, local31, local32, local33

    local1 = false
    local2 = _GetItemQuality(itemref)
    if local2 == 0 then
        local3 = call_0030H(526)
        while local4 do
            local6 = local4
            _SetItemType(889, local6)
            local7 = check_position(128, 10, 440, local6)
            local8 = get_item_position(local6)
            local9 = {local8[1] + 3, local8[2] + 3, local8[3]}
            while local10 do
                local12 = local10
                local13 = get_item_position(local12)
                if local13[1] == local9[1] and local13[2] == local9[2] then
                    delete_item(local12)
                end
                local10 = get_next_item() -- sloop
            end
            local4 = get_next_item() -- sloop
        end
        local3 = call_0030H(889)
        while local14 do
            local6 = local14
            _SetItemType(526, local6)
            local7 = call_0024H(440)
            if not local7 then
                local8 = get_item_position(local6)
                local1 = call_0026H({local8[1] + 3, local8[2] + 3, local8[3]})
            end
            local14 = get_next_item() -- sloop
        end
        local1 = true
    end
    if local2 >= 1 and local2 < 251 then
        local16 = check_position(0, 60, 845, get_item_position(eventid))
        local16 = check_position(0, 60, 828, get_item_position(eventid))
        while local17 do
            local19 = local17
            if _GetItemQuality(local19) == local2 then
                if _GetItemType(local19) == 845 then
                    local1 = call_0820H(local19)
                else
                    local1 = call_081FH(local19)
                end
            end
            local17 = get_next_item() -- sloop
        end
    elseif local2 == 251 then
        if not get_flag(740) then
            local20 = {1, 0, 0}
        end
        if not get_flag(741) then
            local20 = {0, 0, 1}
        end
        if not get_flag(742) then
            local20 = {0, 1, 0}
        end
        if not get_flag(740) and not get_flag(741) and not get_flag(742) then
            local20 = {1, 0, 0}
        end
        local1 = call_0817H(local20)
    elseif local2 == 253 then
        if not get_flag(740) then
            local20 = {1, 0, 0}
        end
        if not get_flag(741) then
            local20 = {0, 0, 1}
        end
        if not get_flag(742) then
            local20 = {0, 1, 0}
        end
        if not get_flag(740) and not get_flag(741) and not get_flag(742) then
            local20 = {0, 0, 1}
        end
        local1 = call_0817H(local20)
    elseif local2 == 252 then
        local1 = false
        local21 = 0
        if not get_flag(740) then
            local21 = 230
        end
        if not get_flag(741) then
            local21 = 220
        end
        if not get_flag(742) then
            local21 = 210
        end
        local22 = get_item_position(eventid)
        local16 = check_position(0, 60, 828, local22)
        local23 = check_position(0, 60, 949, local22)
        while local24 do
            local26 = local24
            local27 = _GetItemQuality(local26)
            if local27 == 230 or local27 == 220 or local27 == 210 or local27 ~= local21 then
                local1 = call_081FH(local26)
            end
            local24 = get_next_item() -- sloop
        end
        while local28 do
            local30 = local28
            if _GetItemQuality(local30) == local21 then
                local1 = call_0820H(local30)
            end
            local28 = get_next_item() -- sloop
        end
        while local31 do
            local33 = local31
            if _GetItemQuality(local33) == local21 then
                local1 = call_0001H({6, -1, 17419, 8014, 1, 8006, 32, 7768}, local33)
                local1 = true
            end
            local31 = get_next_item() -- sloop
        end
        local32 = check_position(0, 12, 270, get_item_position(eventid))
        if local32 ~= 0 then
            call_010EH(local32)
        end
    end
    if local1 then
        local21 = _GetItemFrame(itemref)
        if local21 % 2 == 0 then
            _SetItemFrame(local21 + 1, itemref)
        else
            _SetItemFrame(local21 - 1, itemref)
        end
        call_0086H(itemref, 28)
    else
        call_006AH(0)
    end
end