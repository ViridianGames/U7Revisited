-- Boosts NPC stats (strength, dexterity, intelligence) when using an item, with a cap at 30.
function func_0289H(eventid, itemref)
    if eventid == 1 then
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        if not get_wearer(target) then -- TODO: Implement LuaGetWearer for callis 0031.
            local strength = get_npc_property(target, 0) -- TODO: Implement LuaGetNPCProperty for callis 0020.
            local dexterity = get_npc_property(target, 1)
            local intelligence = get_npc_property(target, 2)
            strength = strength + 5 > 30 and 30 or strength + 5
            dexterity = dexterity + 5 > 30 and 30 or dexterity + 5
            intelligence = intelligence + 5 > 30 and 30 or intelligence + 5
            call_script(0x0835, target, 0, strength) -- TODO: Map 0835H (possibly set_stat).
            call_script(0x0835, target, 1, dexterity)
            call_script(0x0835, target, 2, intelligence)
            set_stat(itemref, 72) -- Sets quality to 72.
            local arr = {7715, 17449, 1, 8021, 1539, 8024, 71}
            execute_action(target, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
            remove_item(itemref) -- TODO: Implement LuaRemoveItem for calli 006F.
        else
            call_script(0x08FD, 60) -- TODO: Map 08FDH (possibly say or error action).
        end
    end
end