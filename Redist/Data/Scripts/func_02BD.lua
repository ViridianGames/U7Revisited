require "U7LuaFuncs"
-- Function 02BD: Lit torch behavior
function func_02BD(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 1 or eventid == 2 then
        call_0839H(595, itemref)
    elseif eventid == 7 then
        local0 = call_0827H(itemref, -356)
        local1 = callis_0001({17505, 17514, 8449, local0, 7769}, -356)
        call_0839H(595, itemref)
    elseif eventid == 5 then
        call_0905H(itemref)
    end

    return
end