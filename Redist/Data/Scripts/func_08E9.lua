--- Best guess: Checks if an item matches specific types and frames, likely for quest item validation, returning 1 if matched or 0 if not.
function func_08E9(var_0000)
    local var_0001, var_0002

    var_0001 = unknown_0011H(var_0000)
    var_0002 = unknown_0012H(var_0000)
    if unknown_0072H(var_0002, var_0001, 1, 356) or unknown_0072H(var_0002, var_0001, 2, 356) or unknown_0072H(var_0002, var_0001, 20, 356) then
        return 1
    end
    return 0
end