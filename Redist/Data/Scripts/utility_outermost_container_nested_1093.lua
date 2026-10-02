--- Best guess: Iterates through nested containers to find the outermost container.
function utility_unknown_1093(objectref)
    local var_0000, var_0001, var_0002

    var_0001 = get_object_container(objectref) --- Guess: Gets item container
    while var_0001 do
        var_0002 = var_0001
        var_0001 = get_object_container(var_0001) --- Guess: Gets item container
    end
    return var_0002
end