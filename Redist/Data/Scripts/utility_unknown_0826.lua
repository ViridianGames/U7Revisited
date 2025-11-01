--- Best guess: Retrieves the location of a Triples game (ID 814) near the Avatar and appends it to an array, returning the array.
function utility_unknown_0826()
    local var_0000, var_0001

    var_0000 = find_nearby_avatar(814)
    var_0001 = get_object_position(var_0000[1])
    table.insert(var_0001, var_0000[1])
    return var_0001
end