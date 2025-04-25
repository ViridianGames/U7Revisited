-- Function 06DD: Triggers item or environmental effect
function func_06DD(eventid, itemref)
    if eventid == 3 then
        call_0836H(1, itemref)
    end

    return
end