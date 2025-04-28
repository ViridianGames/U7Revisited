require "U7LuaFuncs"
-- Manages prism placement near pedestals for the Black Gate.
function func_082E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    external_007EH() -- Unmapped intrinsic
    local1 = external_0035H(0, 20, 168, itemref) -- Unmapped intrinsic
    if not local1 then
        local2 = external_0035H(0, 20, 577, itemref) -- Unmapped intrinsic
        local3 = 0
        for local4 in ipairs(local2) do
            local5 = local4
            local6 = local5
            local7 = get_item_data(local6)
            local8 = external_000EH(1, 981, local6) -- Unmapped intrinsic
            local9 = get_item_data(local8)
            if local9[1] == local7[1] and local9[2] == local7[2] and local9[3] == local7[3] + 2 and get_item_frame(local6) == get_item_frame(local8) then
                local3 = local3 + 1
                if local8 == itemref then
                    local10 = get_item_data(local8)
                    create_object(-1, 2, -1, -1, local10[2], local10[1], 7) -- Unmapped intrinsic
                end
            end
        end
        if local3 == 3 then
            for local11 in ipairs(local1) do
                local12 = local11
                local13 = local12
                external_006FH(local13) -- Unmapped intrinsic
            end
            if not local13 then
                external_0940H(14) -- Unmapped intrinsic
            end
        else
            for local14 in ipairs(local1) do
                local15 = local14
                local13 = local15
                set_item_frame(local13, (local3 * 8 + get_item_frame(local13)) % 8)
            end
        end
    end
    return
end