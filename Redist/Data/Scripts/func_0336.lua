-- Manages diaper usage, changing state or warning about improper use.
function func_0336H(eventid, itemref)
    if eventid == 1 then
        local frame = get_item_frame(itemref)
        if frame == 0 then
            local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
            local item_type = get_item_type(target)
            if item_type == 730 or item_type == 864 then -- 02DAH, 0360H: Likely baby or crib.
                set_item_frame(itemref, 1)
            elseif item_type == 822 and get_item_frame(target) == 2 then -- 0336H: Diaper with specific frame.
                call_script(0x0925, itemref) -- TODO: Map 0925H (possibly item cleanup).
            else
                say(0, "Those are for babies.")
            end
        elseif frame == 1 then
            local target = item_select_modal()
            if get_wearer(target) then -- TODO: Implement LuaGetWearer for callis 0031.
                set_item_status(target, 0) -- TODO: Implement LuaSetItemStatus for calli 001D.
                set_npc_status(target, 7) -- TODO: Implement LuaSetNPCStatus for calli 004B.
                set_npc_state(target, -356) -- TODO: Implement LuaSetNPCState for calli 004C.
                call_script(0x0925, itemref)
            elseif item_type == 822 and get_item_frame(target) == 2 then
                call_script(0x0925, itemref)
            end
        elseif frame == 2 then
            say(0, "That is for dirty diapers.")
        end
    end
end