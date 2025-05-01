-- Casts an explosion spell ("Vas In Flam Grav") on a target area.
function func_0673(p0)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    if get_event_id() == 1 then
        local0 = 25
        external_005CH(itemref) -- Unmapped intrinsic
        local1 = external_0934H(local0) -- Unmapped intrinsic
        bark(itemref, "@Vas In Flam Grav@")
        if not external_0906H() then
            local2 = external_0001H({17514, 17520, 17516, 17517, 8044, 65, 7768}, itemref) -- Unmapped intrinsic
            for local3, local4 in ipairs({{1, -1, 0, 1, 2}, {0, -1, 0, 1, 2}, {-1, -1, 0, 1, 2}, {-2, -1, 0, 1, 2}}) do
                local5 = local4
                local6 = local5[1]
                local7 = local5[2]
                local8 = local5[3]
                local9 = {local6, local7, local8}
                local10 = external_0024H(895) -- Unmapped intrinsic
                if local10 then
                    local2 = external_0026H(local9) -- Unmapped intrinsic
                    external_0089H(local10, 18) -- Unmapped intrinsic
                    local11 = 30
                    local12 = external_0015H(local10, local11) -- Unmapped intrinsic
                    local2 = external_0002H({17453, 7715}, local10) -- Unmapped intrinsic
                end
            end
        else
            local2 = external_0001H({1542, 17493, 17514, 17520, 17516, 17517, 7788}, itemref) -- Unmapped intrinsic
        end
    end
    return
end