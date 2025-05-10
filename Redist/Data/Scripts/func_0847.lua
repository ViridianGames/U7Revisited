--- Best guess: Checks if an item type matches a list (e.g., 400, 414), returning true if found, likely for validation.
function func_0847(eventid, objectref)
    local var_0000

    var_0000 = objectref
    if var_0000 == 400 or var_0000 == 414 or var_0000 == 892 or var_0000 == 762 or var_0000 == 778 or var_0000 == 507 then
        return 1
    end
    return 0
end