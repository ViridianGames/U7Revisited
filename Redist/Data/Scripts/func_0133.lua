require "U7LuaFuncs"
function func_0133H(eventid, itemref)
    if eventid == 1 and U7GetItemFrame(itemref) == 0 then
        local item_pos = U7GetItemInfo(itemref)
        local portion = U7FindItemNearby(itemref, 0, 5, 340)
        local burner_positions = {0, 0, 0}
        local valid_frames = U7CreateArray(2, 7, 8)
        local item2, frame, pos2
        for _, item in ipairs(U7GetNearbyItems(itemref)) do
            pos2 = U7GetItemInfo(item)
            frame = U7GetItemFrame(item)
            if pos2[1] == item_pos[1] - 3 and pos2[2] == item_pos[2] and pos2[3] == item_pos[3] and U7IsFrameValid(frame, valid_frames) then
                U7CallScript(0x0802, valid_frames, frame)
                burner_positions[1] = item
            elseif pos2[1] == item_pos[1] - 2 and pos2[2] == item_pos[2] + 2 and pos2[3] == item_pos[3] and U7IsFrameValid(frame, valid_frames) then
                U7CallScript(0x0802, valid_frames, frame)
                burner_positions[2] = item
            elseif pos2[1] == item_pos[1] and pos2[2] == item_pos[2] + 3 and pos2[3] == item_pos[3] and U7IsFrameValid(frame, valid_frames) then
                U7CallScript(0x0802, valid_frames, frame)
                burner_positions[3] = item
            end
        end
        if burner_positions[1] ~= 0 and burner_positions[2] ~= 0 and burner_positions[3] ~= 0 then
            local potion = U7FindItemNearby(itemref, 0, 5, 754)
            for _, pot in ipairs(potion) do
                local pot_pos = U7GetItemInfo(pot)
                if pot_pos[1] == item_pos[1] + 2 and pot_pos[2] == item_pos[2] - 2 and pot_pos[3] == item_pos[3] then
                    local serum = U7FindItemNearby(itemref, 0, 5, 177)
                    for _, ser in ipairs(serum) do
                        local ser_pos = U7GetItemInfo(ser)
                        if ser_pos[1] == item_pos[1] + 1 and ser_pos[2] == item_pos[2] + 2 and ser_pos[3] == item_pos[3] + 2 then
                            local arr1 = U7CreateArray(7758, 17496, 67, 7975, 10, 8016)
                            U7ExecuteAction(itemref, arr1)
                            U7AddItemsToContainer(burner_positions[1], 1557, 2)
                            U7AddItemsToContainer(burner_positions[2], 1557, 4)
                            U7AddItemsToContainer(burner_positions[3], 1557, 6)
                            local arr2 = U7CreateArray(7758, 17419, -1, 4)
                            U7ExecuteAction(pot, arr2)
                            local arr3 = U7CreateArray(7758, 17419, -1, 3, 8006, 0)
                            U7ExecuteAction(ser, arr3)
                            U7SetGlobalFlag(0x01D0, true)
                            return
                        end
                    end
                end
            end
            local arr4 = U7CreateArray(7758, 17496, 69, 7975, 10, 8016)
            U7ExecuteAction(itemref, arr4)
        end
    else
        U7SetItemFrame(itemref, 0)
    end
end