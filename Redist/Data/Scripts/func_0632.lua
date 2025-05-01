-- Triggers a sprite effect and creates items, likely for a magical or environmental interaction.
function func_0632(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        local0 = get_item_data(-110)
        create_object(-1, 0, 0, 0, local0[2], local0[1], 7) -- Unmapped intrinsic
        local1 = add_item(itemref, {17514, 17520, 17519, 17409, 7715})
        local1 = add_item(itemref, 4, 1586, {17493, 7715})
    elseif eventid == 2 then
        switch_talk_to(110, 0)
        external_003FH(-110) -- Unmapped intrinsic
    end
    return
end