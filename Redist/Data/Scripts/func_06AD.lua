-- Function 06AD: Triggers item-specific function
function func_06AD(eventid, itemref)
    if eventid == 3 then
        call_02C0H(itemref)
    end

    return
end