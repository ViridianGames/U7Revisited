require "U7LuaFuncs"
-- Manages barge movement, checking item types and ferryman presence to trigger ferry operations.
function func_0634(eventid, itemref)
    local local0, local1, local2, local3

    local0 = external_0058H(itemref) -- Unmapped intrinsic
    if local0 then
        local1 = get_item_type(itemref) -- Unmapped intrinsic
        if local1 == 840 then
            external_0812H(local0) -- Unmapped intrinsic
        elseif local1 == 652 then
            external_028CH(itemref) -- Unmapped intrinsic
        elseif local1 == 199 then
            local2 = add_item(-356, 0, 25, 155)
            if local2 and local2 == local0 then
                if get_flag(20, -356) == local2 then
                    external_061CH(local0) -- Unmapped intrinsic
                    set_flag(20, -356, false)
                end
            else
                local3 = get_flag(20, -356)
                if not local3 then
                    external_0831H(local3) -- Unmapped intrinsic
                end
            end
        end
    end
    return
end