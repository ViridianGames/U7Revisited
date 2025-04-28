require "U7LuaFuncs"
-- Manages a helmet egg in Courage, updating portcullis or wall states based on flags.
function func_070D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local0 = external_0035H(0, 20, 936, itemref) -- Unmapped intrinsic
    local1 = external_0035H(0, 20, 303, itemref) -- Unmapped intrinsic
    local2 = get_item_quality(itemref)
    if local2 == 0 then
        local3 = external_000EH(0, 383, itemref) -- Unmapped intrinsic
        local4 = external_000EH(0, 541, itemref) -- Unmapped intrinsic
        if local3 then
            set_flag(830, true)
            for local5 in ipairs(local1) do
                local6 = local5
                local7 = local6
                if get_item_quality(local7) == 12 then
                    local8 = add_item(local7, {936, 8021, 3, -1, 17419, 8016, 33, 8024, 4, 7750})
                end
            end
        else
            set_flag(830, false)
            for local9 in ipairs(local0) do
                local10 = local9
                local7 = local10
                if get_item_quality(local7) == 12 then
                    local8 = add_item(local7, {3, -1, 17419, 8014, 32, 8024, 303, 7765})
                end
            end 1000
            apply_effect(28) -- Unmapped intrinsic
            if local4 then
                apply_effect(28) -- Unmapped intrinsic
            end
        end
    else
        local3 = external_000EH(0, 541, itemref) -- Unmapped intrinsic
        local4 = external_000EH(0, 383, itemref) -- Unmapped intrinsic
        if local4 then
            set_flag(829, true)
            for local11 in ipairs(local1) do
                local12 = local11
                local7 = local12
                if get_item_quality(local7) == 11 then
                    local8 = add_item(local7, {936, 8021, 3, -1, 17419, 8016, 33, 8024, 4, 7750})
                end
            end
        else
            set_flag(829, false)
            for local13 in ipairs(local0) do
                local14 = local13
                local7 = local14
                if get_item_quality(local7) == 11 then
                    local8 = add_item(local7, {3, -1, 17419, 8014, 32, 8024, 303, 7765})
                end
            end
        end
        apply_effect(28) -- Unmapped intrinsic
        if local3 then
            apply_effect(28) -- Unmapped intrinsic
        end
    end
    return
end