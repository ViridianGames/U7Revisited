require "U7LuaFuncs"
-- Function 0811: Update party flags
function func_0811(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = call_093CH(_GetPartyMembers(), -356)
    while local1 do
        local3 = local1
        set_flag(57, true)
        call_001DH(15, local3)
        local1 = get_next_item() -- sloop
    end
end