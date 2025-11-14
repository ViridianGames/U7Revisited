--- Best guess: Manages a mechanic checking an item's frame state (via 081BH), triggering actions (081DH, 0818H) based on frame values (0 or 1), and setting flags or states.
---@param objectref integer The object reference to check
---@return boolean success True if the operation succeeded, false if it failed
function utility_unknown_0799(objectref)
    local var_0001

    var_0001 = utility_unknown_0795(objectref)
    if var_0001 == 1 then
        if utility_position_0797(7, 0, 0, 0, 845, objectref) then
            set_object_quality(objectref, 31)
        else
            utility_unknown_0792(objectref)
            return false
        end
    elseif var_0001 == 0 then
        if utility_position_0797(7, 0, 0, 1, 845, objectref) then
            set_object_quality(objectref, 30)
        else
            utility_unknown_0792(objectref)
            return false
        end
    end
    return true
end