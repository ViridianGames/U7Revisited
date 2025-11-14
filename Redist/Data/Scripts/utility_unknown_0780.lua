--- Best guess: Identifies the type of an item (ID -359) within a radius, returning a specific item ID (840, 652, or 199) based on predefined lists.
---@param objectref integer The object reference to check nearby items for
---@return integer item_id The identified item ID (840, 652, or 199 as default)
function utility_unknown_0780(objectref)
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    var_0001 = find_nearby(0, 2, -359, objectref)
    var_0002 = {840}
    var_0003 = {301, 757, 774, 773, 660, 652, 796}
    for var_0004 in ipairs(var_0001) do
        var_0007 = get_object_shape(var_0006)
        if table.contains(var_0002, var_0007) then
            return 840
        end
        if table.contains(var_0003, var_0007) then
            return 652
        end
    end
    return 199
end