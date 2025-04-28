require "U7LuaFuncs"
-- Handles pickaxe usage on trees or objects, checking for valid targets.
function func_0270H(eventid, itemref)
    if eventid == 1 then
        if not check_item_held(-356, 1, 839, -359) then -- TODO: Implement LuaCheckItemHeld for callis 0072.
            say(0, "Thou must hold that in thine hand.")
            return
        end
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        local item_type = get_item_type(target) -- TODO: Implement LuaGetItemType for callis 0011.
        if item_type == 932 then -- 03A4H: Likely a tree.
            local frame = get_item_frame(target) -- TODO: Implement LuaGetItemFrame for callis 0012.
            if frame == 2 or frame == 3 then
                local arr1 = {2, 2, 2}
                local arr2 = {0, 1, 2}
                local arr3 = {-5}
                call_script(0x0828, target, arr2, arr1, arr3, 624, 7) -- TODO: Map 0828H.
                use_item() -- TODO: Implement LuaUseItem for calli 007E.
            else
                say(0, "It seems the tree will yield nothing of value.")
            end
        else
            say(0, "It seems that a pick is not needed for that.")
        end
    elseif eventid == 7 then
        local items = find_items(-356, 932, 3, 0) -- TODO: Implement LuaFindItems for callis 0035.
        for _, item in ipairs(items) do
            local frame = get_item_frame(item)
            if frame == 2 or frame == 3 then
                call_script(0x092D, item) -- TODO: Map 092DH.
            end
        end
        local arr = {7769, target, 8549, 17447, 8039, 17447, 8037, 17447, 8039, 17447, 8037, 17447, 8039, 17447, 8021, 624}
        execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
    elseif eventid == 2 then
        if not get_flag(0x0321) then
            local obj = find_object_by_type(203) -- TODO: Implement LuaFindObjectByType for callis 0024.
            set_item_frame(obj, 10) -- TODO: Implement LuaSetItemFrame for calli 0013.
            update_container({2426, 1561, 4}) -- TODO: Implement LuaUpdateContainer for callis 0026.
            local items = find_items(-356, 932, 3, 0)
            set_item_frame(items, 3)
            set_flag(0x0321, false)
        else
            local items = find_items(-356, 932, 3, 0)
            for _, item in ipairs(items) do
                local frame = get_item_frame(item)
                if frame == 2 or frame == 3 then
                    local count = 0
                    while count < 3 do
                        local obj = find_object_by_type(912)
                        set_item_frame(obj, 3 - count)
                        local pos = get_item_info(item) -- TODO: Implement LuaGetItemInfo for callis 0018.
                        pos[1] = pos[1] + count + 1
                        pos[2] = pos[2] + 2
                        pos[3] = pos[3] - 3
                        update_container(pos)
                        count = count + 1
                    end
                    local new_item = find_items(item, 810, 5, 0)
                    if new_item then
                        set_item_frame(new_item, 2)
                        set_item_quality(new_item, 4) -- TODO: Implement LuaSetItemQuality for callis 0015.
                    end
                end
            end
        end
    end
end