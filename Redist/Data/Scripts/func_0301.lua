-- Handles smokebomb usage, creating a smoke effect and affecting NPCs.
function func_0301H(eventid, itemref)
    if eventid == 1 or eventid == 4 then
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local npcs = find_items(itemref, 494, 300, 0) -- TODO: Implement LuaFindItems for callis 0035.
        for _, npc in ipairs(npcs) do
            set_item_status(npc, 7) -- TODO: Implement LuaSetItemStatus for calli 001D.
            set_npc_status(npc, 7) -- TODO: Implement LuaSetNPCStatus for calli 004B.
            set_npc_state(npc, -356) -- TODO: Implement LuaSetNPCState for calli 004C.
        end
        local pos = get_item_info(itemref) -- TODO: Implement LuaGetItemInfo for callis 0018.
        set_item_state(itemref) -- TODO: Implement LuaSetItemState for calli 005C.
        create_effect(25, pos[1], pos[2], 0, 0, 3, 2) -- TODO: Implement LuaCreateEffect for calli 0053.
        create_effect(25, pos[1], pos[2], 1, 0, 3, 2)
        create_effect(25, pos[1], pos[2], 2, -2, 3, 2)
        create_effect(25, pos[1], pos[2], 3, 0, 3, 2)
        create_effect(25, pos[1], pos[2], 4, 0, 3, 2)
        create_effect(25, pos[1], pos[2], 1, 2, 3, 2)
        create_effect(25, pos[1], pos[2], 2, 2, 3, 2)
        create_effect(25, pos[1], pos[2], 3, 2, 3, 2)
        create_effect(25, pos[1], pos[2], 4, -2, 3, 2)
        remove_item(itemref) -- TODO: Implement LuaRemoveItem for calli 006F.
    end
end