-- Searches for an item with specific frame and position, applying adjustments if found.
function func_081E(p0, p1, p2, p3, p4, p5, p6, p7, p8)
    local local9, local10, local11, local12, local13, local14, local15

    local9 = get_item_data(p8)
    local10 = local9[p5]
    local11 = external_0035H(0, 7, p7, p8) -- Unmapped intrinsic
    local12 = false
    for local13 in ipairs(local11) do
        local14 = local13
        local15 = local14
        if external_081BH(local15) == p6 and local9[p5] == local10 then -- Unmapped intrinsic
            local12 = true
            break
        end
    end
    if not local12 then
        local12 = external_081DH(p0, p1, p2, p3, p4, local15) -- Unmapped intrinsic
    end
    return
end