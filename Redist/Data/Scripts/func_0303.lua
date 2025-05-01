-- Handles wand usage, triggering specific effects or endgame conditions based on item type.
function func_0303H(eventid, itemref)
    local target
    if eventid == 4 then
        target = itemref
    else
        target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    end
    if target then
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local item_type = get_item_type(target)
        if item_type == 914 then -- 0392H: Likely a specific wand.
            local obj = call_script(0x092D, target) -- TODO: Map 092DH (possibly item effect).
            local arr1 = {7719, 5, 7981}
            execute_action(target, arr1) -- TODO: Implement LuaExecuteAction for callis 0001.
            perform_action(-356, target, 704) -- TODO: Implement LuaPerformAction for callis 0041.
            local arr2 = {7769, obj, 8449, 17511, 17505, 17530}
            execute_action(-356, arr2)
        elseif item_type == 305 then -- 0131H: Black Gate.
            local items = find_items(target, 168, 12, 176) -- TODO: Implement LuaFindItems for callis 0035.
            local batlin = find_items(-356, 403, 80, 0)
            if not batlin and not items then
                set_condition(true) -- TODO: Implement LuaSetCondition for calli 0075.
            else
                switch_talk_to(26, 0)
                say(0, 'The wand glows faintly. Batlin smirks. "Not yet, Avatar."')
                hide_npc(26)
                return
            end
        end
        apply_effect(62) -- TODO: Implement LuaApplyEffect for calli 000F.
        start_endgame() -- TODO: Implement LuaStartEndgame for calli 005D.
    end
end