-- Function 0917: Adjust NPC stats with balanced training
function func_0917(eventid, itemref)
    local local0, local1, local2, local3

    while local0 < eventid do
        local3 = call_0910H(1, itemref)
        local4 = call_0910H(4, itemref)
        local5 = (local4 + local3 + 1) / 2
        if local5 >= local3 then
            local5 = local4 + 1
            if local5 >= 30 then
                local5 = 30
            end
        end
        call_0912H(local5 - local4, 4, itemref)
        call_0912H(-1, 7, itemref)
        local0 = local0 + 1
    end
    return
end