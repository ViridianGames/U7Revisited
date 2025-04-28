require "U7LuaFuncs"
-- Function 0802: Remove element from array
function func_0802(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local2 = {}
    while local3 do
        local5 = local3
        if local5 ~= local1 then
            table.insert(local2, local5)
        end
        local3 = get_next_item() -- sloop
    end
    set_return(local2)
end