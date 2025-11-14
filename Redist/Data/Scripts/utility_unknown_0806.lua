--- Best guess: Checks if an item type is in a specific set (157, 779), likely for validation.
function utility_unknown_0806(objectref)
    local var_0001

    var_0001 = {157, 779}
    if table.contains(var_0001, get_object_shape(objectref)) then --- Guess: Gets item type
        return true
    else
        return false
    end
end