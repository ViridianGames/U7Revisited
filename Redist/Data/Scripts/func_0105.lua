require "U7LuaFuncs"
function func_0105H(eventid, itemref)
    if eventid == 7 then
        U7SetItemState(itemref)
        local arr1 = U7CreateArray(7750, 0, 8014, 17409, 17496, 6, 7947, -4, 32, 8021, 261)
        local result1 = U7ExecuteAction(itemref, arr1)
        local obj = U7GetNearbyObject(itemref, -356)
        local arr2 = U7CreateArray(7769, obj, 8449, 17511, 17447, 1, 7947, -5, 9)
        U7ExecuteAction(-356, arr2)
    elseif eventid == 2 then
        local items = U7GetContainerItems(-356, 654, -359, -359)
        if items == nil then
            U7ProcessItem(items)
        end
        local obj = U7FindObjectByType(851)
        if obj ~= nil then
            U7SetItemQuality(obj, 18)
            U7SetItemQuality(obj, 11)
            local frame = U7Random(0, 4)
            U7SetItemFrame(obj, frame)
            local info = U7GetItemInfo(itemref)
            info[1] = info[1] + 1
            info[2] = info[2] + 1
            U7UpdateContainer(info)
        end
    elseif eventid == 1 then
        U7Say("I believe that one threads a loom before using it.", 0)
    end
end