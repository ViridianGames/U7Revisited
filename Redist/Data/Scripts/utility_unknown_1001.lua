--- Best guess: Checks if an item matches specific types and frames, likely for quest item validation, returning 1 if matched or 0 if not.
function utility_unknown_1001(var_0000)
    local var_0001, var_0002

    var_0001 = get_object_shape(var_0000)
    var_0002 = get_object_frame(var_0000)
    if is_readied(var_0002, var_0001, 1, 356) or is_readied(var_0002, var_0001, 2, 356) or is_readied(var_0002, var_0001, 20, 356) then
        return 1
    end
    return 0
end