--- Best guess: Retrieves the location of a Triples game (ID 814) near the Avatar and appends it to an array, returning the array.
function func_083A()
    local var_0000, var_0001

    var_0000 = unknown_0030H(814)
    var_0001 = unknown_0018H(var_0000[1])
    table.insert(var_0001, var_0000[1])
    return var_0001
end