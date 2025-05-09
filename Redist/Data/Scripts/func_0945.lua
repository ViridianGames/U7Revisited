--- Best guess: Iterates through nested containers to find the outermost container.
function func_0945(eventid, itemref)
    local var_0000, var_0001, var_0002

    var_0001 = get_item_container(itemref) --- Guess: Gets item container
    while var_0001 do
        var_0002 = var_0001
        var_0001 = get_item_container(var_0001) --- Guess: Gets item container
    end
    return var_0002
end