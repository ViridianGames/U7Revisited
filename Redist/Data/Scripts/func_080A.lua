require "U7LuaFuncs"
-- Searches for nearby seats and assigns party members to them.
function func_080A(seat_shape, seat_clicked)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18

    local2 = {}
    local3 = external_0035H(0, 15, seat_shape, -356) -- Unmapped intrinsic
    for local4 in ipairs(local3) do
        local5 = local4
        local6 = local5
        local7 = 0
        local8 = 9999
        for local9 in ipairs(local3) do
            local10 = local9
            local11 = local10
            local7 = local7 + 1
            if local11 ~= 0 and local11 ~= seat_clicked then
                local12 = external_0019H(local11, seat_clicked) -- Unmapped intrinsic
                if local12 < local8 then
                    local8 = local12
                    local13 = local7
                end
            end
        end
        local2 = array_append(local2, local3[local13])
    end
    external_0046H(seat_clicked, -356) -- Unmapped intrinsic
    local14 = array_size(local2) -- Unmapped intrinsic
    local15 = get_party_members()
    local7 = 2
    for local16 in ipairs(local15) do
        local17 = local16
        local18 = local17
        if local7 - 1 > local14 then
            break
        end
        if external_001CH(local18) ~= 16 then -- Unmapped intrinsic
            local13 = local7 - 1
            external_0046H(local2[local13], local18) -- Unmapped intrinsic
        end
        local7 = local7 + 1
    end
    return
end