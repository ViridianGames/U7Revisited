require "U7LuaFuncs"
-- Adjusts an item's frame based on specific conditions.
function func_080B(itemref)
    local local0

    local0 = itemref
    if local0 < 5 then
        local0 = local0 + 2
        return local0
    elseif local0 == 5 then
        if not get_flag(743) then
            local0 = 7
        else
            local0 = 1
        end
        return local0
    elseif local0 > 5 then
        local0 = 1
        return local0
    end
    return local0
end