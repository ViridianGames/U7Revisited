-- Initializes party inventory with specific items and qualities.
function func_084A()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local0 = 1
    local1 = {411, 411, 411, 411, 403, 403, 403, 403}
    local2 = {318, 315, 309, 306, 318, 315, 309, 306}
    local3 = {0, 0, 0, 0, 2, 2, 2, 2}
    local4 = get_party_members()
    for local5 in ipairs(local4) do
        local6 = local5
        local7 = local6
        local8 = local1[local0]
        local8 = array_append(local8, local2[local0])
        local8 = array_append(local8, local3[local0])
        local0 = local0 + 1
        local9 = get_container_items(-359, -359, -359, local7)
        for local10 in ipairs(local9) do
            local11 = local10
            local12 = local11
            local13 = external_0025H(local12) -- Unmapped intrinsic
            if local13 then
                local14 = set_item_data(local8)
            end
        end
    end
    return
end