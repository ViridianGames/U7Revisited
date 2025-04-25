-- Handles interaction with an item, possibly a sextant or navigation tool.
function func_0275H(eventid, itemref)
    local target
    if eventid == 1 then
        target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    else
        target = itemref
    end
    local arr = {7715, 17508, 17512, 17514, 17530, 17508}
    execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
    perform_action(-356, target, 629) -- TODO: Implement LuaPerformAction for callis 0041.
end