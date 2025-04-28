require "U7LuaFuncs"
-- Adjusts an item's frame and type, updating its position.
function func_081D(p0, p1, p2, p3, p4, p5)
    local local6, local7

    external_081CH(p3, p5) -- Unmapped intrinsic
    set_item_type(p5, p4)
    local6 = get_item_data(p5)
    local6[1] = local6[1] + p2
    local6[2] = local6[2] + p1
    if not external_0025H(p5) then -- Unmapped intrinsic
        local7 = set_item_data(local6)
    end
    return true
end