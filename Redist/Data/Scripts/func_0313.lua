-- Manages interaction with an item, possibly a lever or switch, with specific effects.
function func_0313H(eventid, itemref)
    if eventid == 1 then
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local arr1 = {-1, -1, -3}
        local arr2 = {-1, -1, arr1, 787, 7}
        call_script(0x0828, itemref, arr2, arr1, -1, 7) -- TODO: Map 0828H (possibly move or place item).
    elseif eventid == 7 then
        local obj = call_script(0x0827, -356, itemref) -- TODO: Map 0827H (possibly get object).
        local arr = {7769, obj, 8449, 17516, 17505}
        execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        call_script(0x0816, itemref) -- TODO: Map 0816H (possibly apply effect).
    elseif eventid == 2 then
        call_script(0x0816, itemref)
    end
end