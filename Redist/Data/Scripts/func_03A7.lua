-- Function 03A7: Item type switching
function func_03A7(eventid, itemref)
    if eventid == 2 then
        _SetItemType(935, itemref)
        return -- abrt
    elseif eventid == 1 then
        calli_006A(0)
        -- Note: Original has 'db 2c' here, ignored
        call_0832H(876, itemref)
    end
    return
end