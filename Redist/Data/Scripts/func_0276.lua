-- Manages interaction with an item, possibly a map or telescope.
function func_0276H(eventid, itemref)
    local target
    if eventid == 1 then
        target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    else
        target = itemref
    end
    set_item_state(-356) -- TODO: Implement LuaSetItemState for calli 005C.
    local arr = {7715, 17508, 17512, 17514, 17530, 17508}
    execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
    perform_action(-356, target, 630) -- TODO: Implement LuaPerformAction for callis 0041.
end