--- Best guess: Formats a shop price string in gargoyle syntax (e.g., “To sell item for 10 gold.”) for use in shop dialogue.
function utility_shop_1052(P0, P1, P2, P3, P4)
    local var_0000

    var_0000 = "To sell " .. P4 .. P3 .. " for " .. P1 .. " gold" .. P0 .. "."
    return var_0000
end