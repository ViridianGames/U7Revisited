--- Best guess: Displays a list of string options, adds them as answers, and returns the selected option's string.
---@param answers string|table Can be either a string or a table of answer options
---@return string selected_answer The selected answer string
function utility_unknown_1035(answers)
    local var_0000

    save_answers()
    var_0000 = add_answer(answers)
    -- TODO: add_answer() doesn't return anything, so not sure what's going on here
    restore_answers()
    return var_0000
end