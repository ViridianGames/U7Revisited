--- Best guess: Compares the distance between two items to a threshold (20), returning true if less than the threshold, false otherwise, likely for proximity-based triggers.
---@param object_id_1 integer The first object ID
---@param object_id_2 integer The second object ID
---@return boolean is_nearby True if objects are within 20 units of each other, false otherwise
function utility_unknown_1020(object_id_1, object_id_2)
    local var_0002

    var_0002 = get_distance(object_id_1, object_id_2)
    if var_0002 < 20 then
        return true
    end
    return false
end