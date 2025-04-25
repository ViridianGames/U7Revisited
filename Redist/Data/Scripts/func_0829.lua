-- Function 0829: Gangplank manipulation
function func_0829(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local1 = {0, 1, 0, -3}
    local2 = {1, 0, -3, 0}
    local3 = {781, 781, 150, 150}
    local4 = {680}
    local5 = _GetItemType(eventid)
    local6 = _GetItemFrame(eventid)
    local7 = get_item_position(eventid)
    local8 = local3[local6 + 1]
    local9[1] = local1[local6 + 1]
    local9[2] = local2[local6 + 1]
    local9[3] = 1
    if local5 == local8 then
        if not call_082CH(local4, -3, local7, eventid) then
            set_return(false)
        end
        local7 = call_082DH(local5, local9, local7)
    else
        local7 = call_082DH(local5, local9, local7)
        if not call_082CH(local4, -3, local7, eventid) then
            set_return(false)
        end
    end
    if local5 == 150 then
        _SetItemType(781, eventid)
    else
        _SetItemType(150, eventid)
    end
    local10 = call_0025H(eventid)
    if local10 then
        local10 = call_0026H(local7)
        set_return(true)
    else
        set_return(false)
    end
end