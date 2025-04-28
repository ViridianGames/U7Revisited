require "U7LuaFuncs"
function func_0102H(eventid, itemref)
    if eventid == 1 then
        if not U7IsItemValid(itemref) then
            U7SetItemState(itemref)
            U7Say("It is about time!", 0)
        else
            U7CallScript(0x0628, itemref)
        end
    elseif eventid == 8 then
        local items = U7GetContainerItems(-356, 810, -359, -359)
        local container = U7GetItemInfo(itemref)
        container[1] = container[1] - 2
        container[2] = container[2] + 1
        if items ~= nil then
            local obj = U7FindObject(items)
            if obj ~= nil then
                U7SetItemFrame(obj, 4)
                U7UpdateContainer(container)
            end
        end
        local arr = U7CreateArray(7769, 0, 7937, 17516)
        U7ExecuteAction(-356, arr)
    end
end