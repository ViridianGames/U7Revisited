require "U7LuaFuncs"
-- Checks if a gangplank is blocked by nearby items.
function func_082C(p0, p1, p2, p3)
    local local4, local5, local6, local7, local8

    local4 = external_0035H(calculate_distance(p1, -359), p3) -- Unmapped intrinsic
    for local5 in ipairs(local4) do
        local6 = local5
        local7 = local6
        local8 = get_item_data(local7)
        if local8[1] <= p2[1] and local8[1] >= p2[1] + p1 and local8[2] <= p2[2] and local8[2] >= p2[2] + p1 and local8[3] <= 2 and local7 ~= p3 and not contains(p0, get_item_type(local7)) and external_0088H(local7, 24) then -- Unmapped intrinsic
            return true
        end
    end
    return false
end