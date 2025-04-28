require "U7LuaFuncs"
-- Checks nearby items and returns a type based on specific conditions.
function func_080C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    local1 = external_0035H(0, 2, -359, itemref) -- Unmapped intrinsic
    local2 = {840}
    local3 = {301, 757, 774, 773, 660, 652, 796}
    for local4 in ipairs(local1) do
        local5 = local4
        local6 = local5
        local7 = get_item_type(local6)
        if contains(local2, local7) then
            return 840
        elseif contains(local3, local7) then
            return 652
        end
    end
    return 199
end