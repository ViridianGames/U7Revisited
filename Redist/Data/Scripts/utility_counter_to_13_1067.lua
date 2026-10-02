--- Best guess: Increments a counter up to 13 and returns the final value, likely used for tracking or timing.
function utility_unknown_1067(P0)
    local var_0000

    var_0000 = 0
    for _ in ipairs({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}) do
        var_0000 = var_0000 + 1
    end
    return var_0000
end