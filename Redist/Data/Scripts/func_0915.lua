require "U7LuaFuncs"
-- Function 0915: Adjust NPC stats based on training
function func_0915(eventid, itemref)
    local local0, local1, local2, local3, local4

    while local0 < eventid do
        local3 = call_0910H(1, itemref)
        call_0912H(1, 1, itemref)
        local4 = local3 + 1
        local5 = call_0910H(4, itemref)
        local6 = (local4 * local5 + (local3 - 1)) / local3
        call_0912H(local6 - local5, 4, itemref)
        call_0912H(-1, 7, itemref)
        local0 = local0 + 1
    end
    return
end