--- Best guess: Displays a list of string options, adds them as answers, and returns the 1-based index of the selected option.
---@param answers string|table Can be either a string or a table of answer options
---@return integer selected_index The 1-based index of the selected option
function utility_unknown_1036(answers)
    local var_0000

    save_answers()
    var_0000 = add_answer(answers)
    restore_answers()
    return var_0000
end