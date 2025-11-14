--- Best guess: Returns the modulo 4 of an item's frame, likely for state cycling.
---@param objectref integer The object reference to check
---@return integer frame_mod The object's frame modulo 4 (0-3)
function utility_unknown_0795(objectref)
    return get_object_frame(objectref) % 4
end