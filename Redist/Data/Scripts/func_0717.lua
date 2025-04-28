require "U7LuaFuncs"
-- Function 0717: Handle item type 668
function func_0717(eventid, itemref)
    local local0, local1, local2, local3, local4

    if _GetItemType(itemref) == 668 then
        local0 = get_item_position(itemref)
        local1 = call_0025H(itemref)
        if not call_0036H(call_001BH(-356)) then
            call_0026H(local0)
            call_006AH(5)
        end
    else
        local2 = _GetContainerItems(-359, -359, 668, itemref)
        local3 = call_006EH(local2)
        local1 = call_0025H(local2)
        if not call_0036H(call_001BH(-356)) and not call_0036H(local3) then
            call_006AH(5)
        end
    end
    call_0838H(itemref)
end