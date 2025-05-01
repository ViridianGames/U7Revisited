-- Casts the "Vas Oort Hur" spell, creating a powerful wind effect in an area with random outcomes.
function func_0674(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        bark(itemref, "@Vas Oort Hur@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = 70
            set_flag(749, true)
            external_0045H(2) -- Unmapped intrinsic
            local1 = add_item(itemref, {17505, 17514, 17519, 17520, 8047, 65, 7768})
            local1 = add_item(itemref, 8, 1652, {17493, 7715})
            local1 = add_item(itemref, local0, 1674, {17493, 7715})
        else
            local1 = add_item(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        if get_flag(749) then
            local2 = 45
            local3 = external_0934H(local2) -- Unmapped intrinsic
            local4 = get_random(1, #local3)
            local5 = local3[local4]
            if local5 then
                local1 = add_item(local5, 1551, {17493, 7715})
            end
            local1 = add_item(itemref, get_random(3, 8), 1652, {17493, 7715})
        end
    end
    return
end