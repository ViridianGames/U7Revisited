-- Function 06DB: Triggers item-specific effect
function func_06DB(eventid, itemref)
    if eventid == 3 then
        call_0824H(itemref)
    end

    return
end