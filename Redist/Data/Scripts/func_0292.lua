-- Manages cooking dough in an oven, producing bread with random outcomes.
function func_0292H(eventid, itemref)
    if eventid == 1 then
        local frame = get_object_frame(itemref) -- TODO: Implement LuaGetItemFrame for callis 0012.
        if frame == 1 or frame == 2 then
            local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
            local item_type = get_item_type(target) -- TODO: Implement LuaGetItemType for callis 0011.
            if item_type == 831 then -- 033FH: Likely dough.
                local last_created = set_last_created(itemref) -- TODO: Implement LuaSetLastCreated for callis 0025.
                if last_created then
                    local pos = get_item_info(target) -- TODO: Implement LuaGetItemInfo for callis 0018.
                    pos[1] = pos[1] - random(1, 2)
                    pos[3] = pos[3] + 1
                    local updated = update_container(pos) -- TODO: Implement LuaUpdateContainer for callis 0026.
                    if updated then
                        local arr = {7715, 17493, 658}
                        execute_action(itemref, arr, 60) -- TODO: Implement LuaExecuteAction for callis 0002.
                        if random(1, 2) == 1 then
                            add_dialogue(0, "Do not over cook it!")
                        end
                    end
                end
            end
        end
    elseif eventid == 2 then
        local pos = get_item_info(itemref)
        local items = find_items(itemref, 831, 2, 0) -- TODO: Implement LuaFindItems for callis 0035.
        if #items > 0 then
            remove_item(itemref) -- TODO: Implement LuaRemoveItem for calli 006F.
            local food = find_object_by_type(377) -- 0179H: Likely bread.
            if food then
                set_object_frame(food, 12)
                set_item_quality(food, 11)
                update_container(pos)
                local outcome = random(1, 3)
                if outcome == 1 then
                    add_dialogue(0, "I believe the bread is ready.")
                elseif outcome == 2 then
                    add_dialogue(0, "Mmm... Smells good.")
                end
            end
        end
    end
end