require "U7LuaFuncs"
-- Searches for specific items around an object and processes them.
function func_080F()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    if get_event_id() == 3 then
        local0 = external_0035H(0, 15, 867, itemref) -- Unmapped intrinsic
        local1 = external_0035H(0, 15, 338, itemref) -- Unmapped intrinsic
        local2 = external_0035H(0, 15, 336, itemref) -- Unmapped intrinsic
        local3 = external_0035H(176, 15, 810, itemref) -- Unmapped intrinsic
        local4 = external_0035H(128, 15, 912, itemref) -- Unmapped intrinsic
        local5 = external_0035H(0, 15, 636, itemref) -- Unmapped intrinsic
        local6 = external_0035H(176, 15, 168, itemref) -- Unmapped intrinsic
        local7 = {local0, local1, local2, local3, local4, local5, local6}
        for local8, local9 in ipairs(local7) do
            local10 = local9
            external_006FH(local10) -- Unmapped intrinsic
        end
    end
    return
end