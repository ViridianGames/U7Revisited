--- Best guess: Formats a shop price string (e.g., “sells ham for 10 gold.”) based on item name, price, and quantity, adjusting verb for singular/plural.
function utility_shop_1051(P0, P1, P2, P3, P4)
    local var_0000

    var_0000 = P4 .. " " .. P3
    if P2 == 1 then
        var_0000 = var_0000 .. "sell "
    else
        var_0000 = var_0000 .. "sells "
    end
    var_0000 = var_0000 .. "for " .. P1 .. " gold" .. P0 .. "."
    return var_0000
end