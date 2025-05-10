--- Best guess: Checks if an item type matches a list (e.g., 519, 354), returning true if found, likely for validation.
function func_0849(eventid, objectref)
    local var_0000

    var_0000 = objectref
    if var_0000 == 519 or var_0000 == 354 or var_0000 == 528 or var_0000 == 337 or var_0000 == 317 or var_0000 == 299 then
        return 1
    end
    return 0
end