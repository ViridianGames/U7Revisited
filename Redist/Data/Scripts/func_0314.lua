-- Manages interaction with a lever or switch, toggling its frame and triggering effects.
function func_0314H(eventid, itemref)
    if eventid == 1 then
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local arr1 = {-1, -1, -3}
        local arr2 = {-1, -1, arr1, 788, 7}
        call_script(0x0828, itemref, arr2, arr1, -1, 7) -- TODO: Map 0828H (possibly move or place item).
    elseif eventid == 7 or eventid == 2 then
        if eventid ~= 2 then
            local obj = call_script(0x0827, -356, itemref) -- TODO: Map 0827H (possibly get object).
            local arr = {7769, obj, 8449, 17511, 17505}
            execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        end
        local frame = get_item_frame(itemref)
        if frame % 2 == 0 then
            set_item_frame(itemref, frame + 1)
        else
            set_item_frame(itemref, frame - 1)
        end
        set_stat(itemref, 28)
        local items1 = find_items(itemref, 870, 15, 0)
        local items2 = find_items(itemref, 515, 15, 0)
        local items = {}
        for _, item in ipairs(items1) do
            table.insert(items, item)
        end
        for _, item in ipairs(items2) do
            if get_item_quality(item) == get_item_quality(itemref) then
                table.insert(items, item)
            end
        end
        local result = call_script(0x080E, items) -- TODO: Map 080EH (possibly apply effect).
        call_script(0x0836, itemref, -359) -- TODO: Map 0836H (possibly update state).
    end
end