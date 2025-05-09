--- Best guess: Checks if an item type is in a specific set (157, 779), likely for validation.
function func_0826(eventid, itemref)
    local var_0000, var_0001

    var_0000 = itemref
    var_0001 = {157, 779}
    if table.contains(var_0001, get_item_type(var_0000)) then --- Guess: Gets item type
        return true
    else
        return false
    end
end