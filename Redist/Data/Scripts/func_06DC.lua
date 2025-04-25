-- Function 06DC: Resets or disables state
function func_06DC(eventid, itemref)
    if eventid == 3 then
        callis_0075(false)
    end

    return
end