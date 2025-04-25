-- Function 0914: Increment NPC stats
function func_0914(eventid, itemref)
    local local0

    while local0 < eventid do
        call_0912H(1, 0, itemref)
        call_0912H(1, 3, itemref)
        call_0912H(-1, 7, itemref)
        local0 = local0 + 1
    end
    return
end