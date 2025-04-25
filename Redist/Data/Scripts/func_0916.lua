-- Function 0916: Increment NPC secondary stats
function func_0916(eventid, itemref)
    local local0, local1

    while local0 < eventid do
        local3 = call_0910H(2, itemref)
        call_0912H(1, 2, itemref)
        call_0912H(-1, 7, itemref)
        local0 = local0 + 1
    end
    return
end