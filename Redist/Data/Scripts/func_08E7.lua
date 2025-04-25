-- Function 08E7: Manages position check function
function func_08E7()
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    local0 = callis_0018(callis_001B(-356))
    local1 = {1392, 1936}
    local2 = {1743, 2495}
    if local0[1] >= local1[1] and local0[2] >= local1[2] and local0[1] <= local2[1] and local0[2] <= local2[2] then
        return 1
    end
    return 0
end