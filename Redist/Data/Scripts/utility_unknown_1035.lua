--- Best guess: Displays a list of string options, adds them as answers, and returns the selected option's string.
---@param P0 string|table Can be either a string or a table
---@return string
function utility_unknown_1035(P0)
    local var_0000

    save_answers()
    var_0000 = add_answer(P0)
    -- TODO: add_answer() doesn't return anything, so not sure what's going on here
    restore_answers()
    return var_0000
end