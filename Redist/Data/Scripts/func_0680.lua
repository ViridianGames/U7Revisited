-- Casts the "Vas Kal An Mani" spell, attempting to resurrect a target, or dealing damage if failed.
function func_0680(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        bark(itemref, "@Vas Kal An Mani@")
        if not external_0906H() then -- Unmapped intrinsic
            local0 = get_item_data(itemref)
            create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7) -- Unmapped intrinsic
            external_0045H(2) -- Unmapped intrinsic
            local1 = add_item(itemref, {1664, 17493, 17505, 17516, 17511, 8047, 67, 17496, 17520, 17519, 17505, 17517, 17517, 8045, 65, 7768})
        else
            local1 = add_item(itemref, {1542, 17493, 17505, 17516, 17511, 17519, 17520, 17519, 17505, 17517, 17518, 7789})
        end
    elseif eventid == 2 then
        bark(itemref, "@In Corp Hur Tym@")
        external_0059H(40) -- Unmapped intrinsic
        external_005BH() -- Unmapped intrinsic
        set_flag(30, true)
    end
    return
end