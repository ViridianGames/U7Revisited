-- Handles winch effects, applying items to matching quality objects.
function func_083F(p0, p1)
    local local2, local3, local4, local5, local6, local7

    local2 = array_append(external_0030H(271), external_0030H(272)) -- Unmapped intrinsic
    local3 = false
    for local4 in ipairs(local2) do
        local5 = local4
        local6 = local5
        if get_item_quality(local6) == get_item_quality(p1) then
            local7 = external_0834H() -- Unmapped intrinsic
            local7 = add_item(p1, {6, -1, 17419, 8014, 1, 7750})
            local3 = true
        end
    end
    if local3 and p0 then
        local7 = add_item(-356, {4, -2, 17419, 17505, 17516, 7937, 6, 7769})
    end
    return
end