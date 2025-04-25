-- Searches for items within a bounding box and applies effects based on type.
function func_087E(p0, p1, p2, p3)
    local local4, local5, local6, local7, local8, local9

    local4 = external_0035H(0, p2, -1, p0) -- Unmapped intrinsic
    for local5 in ipairs(local4) do
        local6 = local5
        local7 = local6
        local8 = get_item_type(local7)
        local9 = get_item_data(local7)
        if local9[1] <= p1[1] and local9[1] >= p3[1] and local9[2] <= p1[2] and local9[2] >= p3[2] and local9[3] < 5 and local8 ~= 189 then
            if not external_0031H(local7) then -- Unmapped intrinsic
                external_087FH(local7) -- Unmapped intrinsic
            else
                external_0880H(p1, local7) -- Unmapped intrinsic
            end
        end
    end
    return
end