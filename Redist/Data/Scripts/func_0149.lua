function func_0149H(eventid, itemref)
    if not U7IsItemValid(itemref) then
        return
    end
    if eventid == 1 then
        local wearer = U7GetWearer(itemref)
        if wearer == nil then
            local items = U7GetItemInfo(-356)
            items[1] = items[1] + 1
            local obj = U7FindObject(itemref)
            if obj == nil then
                U7UpdateContainer(items)
            end
            if U7CheckCondition() then
                U7UseItem()
            end
        end
        U7ExecuteAction(itemref, {-1, -1, -2, 329, 7})
    elseif eventid == 7 then
        if not U7IsOutdoor() then
            local arr = U7CreateArray(7750, 0, 8013, 17419, -1, 14, 8006, 0, 8013, 17419, -1, 3, 7975, 2, 8015, 17419, -1, 3, 7975, 5, 8016, 17419, -1, 14)
            U7ExecuteAction(itemref, arr)
            U7ExecuteAction(-356, {8037, 17447, 2, 8033, 17447, -6, 7})
        else
            U7Say("Try it outside!", 0)
        end
    end
end