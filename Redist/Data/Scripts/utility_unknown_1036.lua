--- Best guess: Displays a list of string options, adds them as answers, and returns the 1-based index of the selected option.
function utility_unknown_1036(P0)
    local var_0000

    save_answers()
    var_0000 = add_answer(P0)
    restore_answers()
    return var_0000
end