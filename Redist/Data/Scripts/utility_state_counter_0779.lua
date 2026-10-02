--- Best guess: Manages a state counter, adjusting its value based on comparisons and flag 743, returning the final state.
function utility_unknown_0779()
    local var_0000

    if var_0000 < 5 then
        var_0000 = var_0000 + 2
        return var_0000
    end
    if var_0000 == 5 then
        if not get_flag(743) then
            var_0000 = 7
        else
            var_0000 = 1
        end
        return var_0000
    end
    if var_0000 > 5 then
        var_0000 = 1
        return var_0000
    end
end