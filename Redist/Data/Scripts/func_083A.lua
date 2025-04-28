require "U7LuaFuncs"
-- Retrieves the position of a triples game near the Avatar.
function func_083A()
    local local0, local1

    local0 = external_0030H(814) -- Unmapped intrinsic
    local1 = get_item_data(local0[1])
    local1 = array_append(local1, local0[1])
    return local1
end