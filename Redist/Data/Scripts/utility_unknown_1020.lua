--- Best guess: Compares the distance between two items to a threshold (20), returning true if less than the threshold, false otherwise, likely for proximity-based triggers.
function utility_unknown_1020(var_0000, var_0001)
    local var_0002

    var_0002 = get_distance(var_0000, var_0001)
    if var_0002 < 20 then
        return true
    end
    return false
end