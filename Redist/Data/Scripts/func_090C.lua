--- Best guess: Displays a list of string options, adds them as answers, and returns the 1-based index of the selected option.
function func_090C(P0)
    local var_0000

    save_answers()
    var_0000 = add_answer(P0)
    restore_answers()
    return var_0000
end