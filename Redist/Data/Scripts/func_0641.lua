-- Casts the "Rel Hur" spell, manipulating wind or movement, with random effects or a fallback if the spell fails.
function func_0641(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        item_say("@Rel Hur@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {68, 17496, 17511, 7781})
            local1 = {2, 1, 0}
            local2 = external_0044H() -- Unmapped intrinsic
            if local2 == 0 then
                local3 = local1[get_random(2, 3)]
                external_0045H(local3) -- Unmapped intrinsic
            elseif local2 ~= 3 then
                external_0045H(0) -- Unmapped intrinsic
            end
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    end
    return
end