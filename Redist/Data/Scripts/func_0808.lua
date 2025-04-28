require "U7LuaFuncs"
-- Function 0808: Update party flags
function func_0808(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = call_093CH(_GetPartyMembers(), -356)
    local1 = call_001CH(-356)
    while local2 do
        local4 = local2
        set_flag(57, false)
        call_001DH(local1, local4)
        local2 = get_next_item() -- sloop
    end
end