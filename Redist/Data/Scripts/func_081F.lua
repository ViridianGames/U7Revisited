require "U7LuaFuncs"
-- Checks an item's frame and applies specific adjustments or effects.
function func_081F(eventid, itemref)
    local local1

    local1 = external_081BH(itemref) -- Unmapped intrinsic
    if local1 == 1 then
        if not external_081DH(7, 0, 0, 0, 845, itemref) then -- Unmapped intrinsic
            external_0086H(itemref, 31) -- Unmapped intrinsic
        else
            external_0818H() -- Unmapped intrinsic
            return false
        end
    elseif local1 == 0 then
        if not external_081DH(7, 0, 0, 1, 845, itemref) then -- Unmapped intrinsic
            external_0086H(itemref, 30) -- Unmapped intrinsic
        else
            external_0818H() -- Unmapped intrinsic
            return false
        end
    end
    return true
end