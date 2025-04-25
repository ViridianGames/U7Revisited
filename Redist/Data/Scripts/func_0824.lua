-- Function 0824: Update item position and type
function func_0824(eventid, itemref)
    local local0, local1, local2, local3, local4

    if _Random2(3, 1) == 1 and _GetItemQuality(eventid) ~= 8 then
        call_0071H(4, 3, -356)
        call_0086H(itemref, 62)
        local1 = get_item_position(-356)
        local2 = get_item_position(eventid)
        local3 = _GetItemType(eventid)
        if local3 == 776 or local3 == 777 or local3 == 779 then
            local1 = call_0825H(2, local2, local1)
        elseif local3 == 157 then
            local1 = call_0825H(1, local2, local1)
        end
        call_003EH(local1, -356)
    else
        call_008CH(0, 1, 12)
        call_0086H(itemref, 11)
        call_0823H(eventid)
        call_003EH(-357)
        call_0001H({1590, 17493, 7715}, -356)
    end
end