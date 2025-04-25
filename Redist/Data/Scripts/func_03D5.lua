-- Function 03D5: Item interaction with positioning
function func_03D5(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        return
    end

    local0 = _ItemSelectModal()
    local1 = _GetItemType(local0)
    local2 = callis_0018(local0)
    if local1 == 577 and _GetItemFrame(local0) == _GetItemFrame(itemref) then
        local3 = callis_0025(itemref)
        if local3 then
            -- Note: Original has 'db 46' here, ignored
            local3 = callis_0026(local2)
        end
    else
        calli_006A(0)
    end
    local3 = call_082EH(itemref)

    return
end