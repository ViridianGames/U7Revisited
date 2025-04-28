require "U7LuaFuncs"
-- Formats a shop price string for an item.
function func_091B(p0, p1, p2, p3, p4)
    local local5

    local5 = p4 .. p3 .. " "
    if p2 == 1 then
        local5 = local5 .. "sell "
    else
        local5 = local5 .. "sells "
    end
    local5 = local5 .. "for " .. p1 .. " gold" .. p0 .. "."
    return local5
end