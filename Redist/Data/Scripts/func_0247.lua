-- Manages bedroll usage, checking space and setting up a bed.
function func_0247H(eventid, itemref)
    if eventid == 1 and not get_wearer(itemref) then -- TODO: Implement LuaGetWearer for callis 006E.
        local location = get_item_info(itemref) -- TODO: Implement LuaGetItemInfo for callis 0018.
        if get_item_frame(itemref) == 0 then -- TODO: Implement LuaGetItemFrame for callis 0012.
            local last_created = set_last_created(itemref) -- TODO: Implement LuaSetLastCreated for callis 0025.
            if last_created then
                local can_place = check_horizontal_space(1011, 17, location) -- TODO: Implement LuaCheckHorizontalSpace for callis 0085.
                local container = update_container(location) -- TODO: Implement LuaUpdateContainer for callis 0026.
                if can_place and container then
                    use_item() -- TODO: Implement LuaUseItem for calli 007E.
                    local arr1 = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
                    local arr2 = {1, 0, -1, 1, 0, -1, 1, 0, -1}
                    set_item_state(-356) -- TODO: Implement LuaSetItemState for calli 005C.
                    call_script(0x0828, itemref, arr1, arr2, -1, 583, 7) -- TODO: Map 0828H.
                else
                    location[2] = location[2] - 5
                    add_dialogue(0, "There is no room for thy bedroll there.")
                end
            end
        end
    elseif eventid == 7 then
        local arr = {7769, 17456, 17516, 17505}
        execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        call_script(0x0828, itemref, {7719, 2, 8021, 583}) -- TODO: Map 0828H.
    elseif eventid == 2 then
        set_item_type(itemref, 1011) -- 03F3H: Bed.
        set_item_frame(itemref, 17) -- TODO: Implement LuaSetItemFrame for calli 0013.
    end
end