-- Function 0836: Update item types
function func_0836(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    local2 = _GetItemQuality(itemref)
    local3 = {}
    if eventid == 1 or eventid == -359 then
        table.insert(local3, call_0030H(303))
        table.insert(local3, call_0030H(876))
    end
    if eventid == 0 or eventid == -359 then
        table.insert(local3, call_0030H(936))
        table.insert(local3, call_0030H(935))
    end
    if #local3 == 0 then
        while local4 do
            local6 = local4
            if _GetItemQuality(local6) == local2 then
                local7 = _GetItemType(local6)
                if local7 == 303 then
                    call_0832H(936, local6)
                elseif local7 == 876 then
                    call_0832H(935, local6)
                elseif local7 == 936 then
                    call_0833H(303, local6)
                elseif local7 == 935 then
                    call_0833H(876, local6)
                end
            end
            local4 = get_next_item() -- sloop
        end
    end
end