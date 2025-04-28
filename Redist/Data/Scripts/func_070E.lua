require "U7LuaFuncs"
-- Manages door states in Courage based on helmet egg flags, updating portcullis or wall frames.
function func_070E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local0 = external_0035H(0, 1, 936, itemref) -- Unmapped intrinsic
    local1 = external_0035H(0, 1, 303, itemref) -- Unmapped intrinsic
    if get_flag(829) and get_flag(830) then
        for local2 in ipairs(local1) do
            local3 = local2
            local4 = local3
            local5 = get_item_data(local4)
            local6 = get_item_quality(local4)
            external_006FH(local4) -- Unmapped intrinsic
            local7 = get_item_by_type(936) -- Unmapped intrinsic
            set_item_frame(local7, 0)
            local8 = external_0015H(local7, local6) -- Unmapped intrinsic
            local8 = set_item_data(local5)
        end
    elseif get_flag(829) then
        for local9 in ipairs(local1) do
            local10 = local9
            local4 = local10
            local6 = get_item_quality(local4)
            if local6 == 11 then
                local5 = get_item_data(local4)
                external_006FH(local4) -- Unmapped intrinsic
                local7 = get_item_by_type(936) -- Unmapped intrinsic
                set_item_frame(local7, 0)
                local8 = external_0015H(local7, local6) -- Unmapped intrinsic
                local8 = set_item_data(local5)
            end
        end
        for local11 in ipairs(local0) do
            local12 = local11
            local4 = local12
            local6 = get_item_quality(local4)
            if local6 == 12 then
                local5 = get_item_data(local4)
                external_006FH(local4) -- Unmapped intrinsic
                local7 = get_item_by_type(303) -- Unmapped intrinsic
                set_item_frame(local7, 4)
                local8 = external_0015H(local7, local6) -- Unmapped intrinsic
                local8 = set_item_data(local5)
            end
        end
    elseif get_flag(830) then
        for local13 in ipairs(local1) do
            local14 = local13
            local4 = local14
            local6 = get_item_quality(local4)
            if local6 == 12 then
                local5 = get_item_data(local4)
                external_006FH(local4) -- Unmapped intrinsic
                local7 = get_item_by_type(936) -- Unmapped intrinsic
                set_item_frame(local7, 0)
                local8 = external_0015H(local7, local6) -- Unmapped intrinsic
                local8 = set_item_data(local5)
            end
        end
        for local15 in ipairs(local0) do
            local16 = local15
            local4 = local16
            local6 = get_item_quality(local4)
            if local6 == 11 then
                local5 = get_item_data(local4)
                external_006FH(local4) -- Unmapped intrinsic
                local7 = get_item_by_type(303) -- Unmapped intrinsic
                set_item_frame(local7, 4)
                local8 = external_0015H(local7, local6) -- Unmapped intrinsic
                local8 = set_item_data(local5)
            end
        end
    else
        for local17 in ipairs(local0) do
            local18 = local17
            local4 = local18
            local5 = get_item_data(local4)
            local6 = get_item_quality(local4)
            external_006FH(local4) -- Unmapped intrinsic
            local7 = get_item_by_type(303) -- Unmapped intrinsic
            set_item_frame(local7, 4)
            local8 = external_0015H(local7, local6) -- Unmapped intrinsic
            local8 = set_item_data(local5)
        end
    end
    return
end