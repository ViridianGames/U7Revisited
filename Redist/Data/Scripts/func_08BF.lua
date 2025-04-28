require "U7LuaFuncs"
-- Function 08BF: Manages stat comparison and adjustment
function func_08BF(local0)
    -- Local variables (3 as per .localc)
    local local1, local2, local3

    local1 = call_0910H(0, local0)
    local2 = call_0910H(3, local0)
    if local1 > local2 then
        local3 = local1 - local2
        call_0912H(local3, 3, local0)
    end

    return
end