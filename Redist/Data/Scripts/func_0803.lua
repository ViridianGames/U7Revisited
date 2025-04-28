require "U7LuaFuncs"
-- Function 0803: Initialize raft
function func_0803(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local1 = check_position(0, 40, 230, eventid)
    if call_0088H(1, local1) then
        local1 = 0
    end
    if not get_flag(3) and not local1 then
        _SetItemType(981, eventid)
        set_flag(3, true)
        local2 = {885, 2743, 0}
        call_003EH(local2, eventid)
        local2[2] = local2[2] + 2
        call_003EH(local2, -356)
        call_0808H()
        local3 = 200
        local4 = 1
        local5 = -359
        call_0804H(local5, local4, local3)
        local6 = call_0002H(8, 1566, {17493, 7715}, -356)
    end
end