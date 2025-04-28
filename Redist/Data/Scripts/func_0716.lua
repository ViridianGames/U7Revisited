require "U7LuaFuncs"
-- Resets a flag and initiates an endgame sequence similar to func_0715.
function func_0716(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    set_flag(806, false)
    local0 = external_0035H(8, 40, 1015, external_001BH(-356)) -- Unmapped intrinsic
    local1 = false
    for local2 in ipairs(local0) do
        local3 = local2
        local4 = local3
        if get_container_items(4, 243, 797, local4) then -- Unmapped intrinsic
            local1 = local4
        end
        if get_container_items(4, 244, 797, local4) then -- Unmapped intrinsic
            local1 = local4
        end
    end
    if local1 then
        set_item_frame(local1, 29)
    end
    local5 = add_item(external_001BH(-356), {1813, 17493, 7715}) -- Unmapped intrinsic
    return
end