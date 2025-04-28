require "U7LuaFuncs"
-- Function 06FA: Displays environmental messages
function func_06FA(eventid, itemref)
    local item_type = call_GetItemType(itemref)

    if item_type == 275 then
        call_08FFH("It would seem the nearby island is not at all stable.")
    elseif item_type == 721 or item_type == 989 then
        call_08FFH("All is not right in Britannia. Perhaps Lord British will know the reason behind this tremor.")
    end

    return
end