-- Function 02B8: Delegate to external function
function func_02B8(eventid, itemref)
    if eventid == 1 then
        call_0800H(itemref)
    end
    return
end