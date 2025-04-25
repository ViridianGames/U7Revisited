-- Formats a shop price string for an item with a "To sell" prefix.
function func_091C(p0, p1, p2, p3, p4)
    local local5

    local5 = "To sell " .. p4 .. p3 .. " for " .. p1 .. " gold" .. p0 .. "."
    return local5
end