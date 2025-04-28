require "U7LuaFuncs"
-- Function 08E9: Manages item type and frame check function
function func_08E9(local0)
    -- Local variables (2 as per .localc)
    local local1, local2

    local1 = callis_0011(local0)
    local2 = callis_0012(local0)
    if callis_0072(local2, local1, 1, -356) or callis_0072(local2, local1, 2, -356) or callis_0072(local2, local1, 20, -356) then
        return 1
    end
    return 0
end