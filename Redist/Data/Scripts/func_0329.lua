-- Simulates spinning a top, with random outcomes and visual effects.
function func_0329H(eventid, itemref)
    if eventid == 1 and not check_in_usecode(itemref) then -- TODO: Implement LuaCheckInUsecode for callis 0079.
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        call_script(0x083C) -- TODO: Map 083CH (possibly initialize effect).
        local state = call_script(0x083A) -- TODO: Map 083AH (possibly get state).
        if get_time_hour() >= 15 or get_time_hour() <= 3 then -- TODO: Implement LuaGetTimeHour for callis 0038.
            while true do
                set_item_quality(itemref, 11) -- TODO: Implement LuaSetItemQuality for calli 008A.
            end
        end
        set_item_status(-232, 9) -- TODO: Implement LuaSetItemStatus for calli 001D.
        local items1 = find_objects_by_type(814) -- TODO: Implement LuaFindObjectsByType for callis 0030.
        local items2 = find_objects_by_type(809)
        local items3 = find_objects_by_type(818)
        if #items3 > 0 or #items2 ~= 3 or #items1 < 1 then
            return
        end
        set_flag(0x001F, false)
        set_flag(0x0020, false)
        set_flag(0x0021, false)
        say(-356, "Spin baby!")
        while true do
            local angle = random(0, 2) * 8
            set_item_state(itemref) -- TODO: Implement LuaSetItemState for calli 005C.
            local arr = {7758, 17496, 29, 7947, -3, 22, 8014, 17496, 29, 7947, -3, angle, 8533, 1547}
            execute_action(itemref, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        end
    end
end