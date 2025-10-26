--- Returns the position of an object as a table {x, y, z}
function func_0018(objectref)
    local x, y, z = get_object_position(objectref)
    return {x, y, z}  -- Return as array [1]=x, [2]=y, [3]=z
end
