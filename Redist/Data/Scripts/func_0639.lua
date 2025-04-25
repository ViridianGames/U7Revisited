-- Handles the "Kal Ort Por" teleportation spell, triggering a sprite effect and endgame sequence.
function func_0639(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        local0 = add_item(itemref, {1593, 17493, 17514, 17520, 17519, 7521, "@Kal Ort Por@", 8018, 1, 17447, 17517, 17456, 7769})
    elseif eventid == 2 then
        local1 = get_item_data(itemref)
        create_object(-1, 2, 0, 0, local1[2], local1[1], 7) -- Unmapped intrinsic
        external_060FH(itemref) -- Unmapped intrinsic
        set_schedule(itemref, 15)
        external_003EH(itemref, {1280, 1450}) -- Unmapped intrinsic
    end
    return
end