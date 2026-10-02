--- Best guess: Manages item quantity, decrementing or removing items based on quantity.
function utility_unknown_1061(arg1)
    local var_0000, var_0001, var_0002

    var_0001 = get_object_quantity(arg1, 356) --- Guess: Gets item quantity
    if var_0001 <= 1 then
        remove_item(arg1) --- Guess: Unknown function, possibly removes item
    else
        var_0001 = var_0001 - 1
        var_0002 = set_object_quantity(arg1, var_0001) --- Guess: Sets item quantity
    end
end