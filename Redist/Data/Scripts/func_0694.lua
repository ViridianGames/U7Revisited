-- Function 0694: Update item frame and position
function func_0694(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    local0 = _GetItemFrame(itemref)
    local1 = 0
    local2 = 0
    if local0 == 1 then
        local1 = 16
        local2 = 19
    elseif local0 == 2 then
        local1 = 0
        local2 = 3
    elseif local0 == 3 then
        local1 = 20
        local2 = 23
    elseif local0 == 4 or local0 == 5 then
        local1 = 12
        local2 = 15
    elseif local0 == 6 then
        return
    end
    local3 = get_item_position(call_001BH(-356))
    local5 = call_0024H(912)
    call_0089H(18, local5)
    _SetItemFrame(_Random2(local1, local2), local5)
    local6 = call_0026H(local4)
    local7 = _GetItemQuality(itemref)
    if local0 == 2 and local7 then
        local7 = local7 - 1
        local8 = _SetItemQuality(local7, itemref)
    else
        local9 = call_0001H(0, {7750}, itemref)
    end
    call_000FH(40)
end