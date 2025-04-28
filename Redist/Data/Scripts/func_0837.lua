require "U7LuaFuncs"
-- Function 0837: Adjust item position and properties
function func_0837(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local5 = get_item_position(local3)
    local5[1] = local5[1] + local2
    local5[2] = local5[2] + local1
    local5[3] = local5[3] + local0
    local6 = call_006EH(itemref)
    local7 = get_item_position(itemref)
    local8 = call_0025H(itemref)
    if not call_0085H(_GetItemType(itemref), _GetItemFrame(itemref), local5) then
        if call_0026H(local5) then
            call_000FH(73)
            set_return(1)
        end
    elseif local6 then
        if not call_0036H(local6) then
            set_return(0)
        end
    elseif call_0026H(local7) then
        set_return(0)
    end
end