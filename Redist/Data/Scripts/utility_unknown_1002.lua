--- Best guess: Checks if an item matches a specific type and frame, likely for quest item validation, returning 1 if matched or 0 if not.
function utility_unknown_1002(var_0000)
    local var_0001, var_0002

    var_0001 = get_object_shape(var_0000)
    var_0002 = get_object_frame(var_0000)
    if is_readied(var_0002, var_0001, 0, 356) then
        return 1
    end
    return 0
end