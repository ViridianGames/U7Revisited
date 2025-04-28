require "U7LuaFuncs"
-- Function 0913: Find party member index
function func_0913(eventid, itemref)
    local local0, local1, local2, local3

    local2 = 0
    while local0 do
        local3 = local0
        local2 = local2 + 1
        if itemref == local3 then
            set_return(local2)
        end
        local0 = get_next_party_member() -- sloop
    end
    set_return(0)
end