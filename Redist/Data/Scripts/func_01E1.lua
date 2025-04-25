-- Function 01E1: Delegate to external function
function func_01E1(eventid, itemref)
    -- No local variables (as per .localc)
    if eventid == 1 or eventid == 2 then
        call_0942H(435, itemref)
    end
    return
end