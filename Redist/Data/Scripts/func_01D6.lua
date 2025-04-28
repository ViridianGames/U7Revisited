require "U7LuaFuncs"
-- Function 01D6: Container item check and positioning
function func_01D6(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    -- Check for item 810 in container
    local0 = _GetContainerItems(-359, -359, 810, -356)
    if local0 then
        return
    end

    -- Create offset arrays
    local1 = {-5, -5}
    local2 = {-1, -1}

    -- Call positioning function
    call_0828H(9, local0, 810, 0, local2, local1, itemref)

    return
end