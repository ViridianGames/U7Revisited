require "U7LuaFuncs"
-- Function 02BA: Cloth to bandages transformation
function func_02BA(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    local0 = _ItemSelectModal()
    local1 = _GetItemType(local0[1])
    if local1 == 851 then
        _SetItemType(827, local0)
        _SetItemFrame(_Random2(0, 2), local0)
    else
        call_08FFH("@Might not those come in handy for cutting cloth into bandages?@")
    end

    return
end