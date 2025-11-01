--- Best guess: Displays a list of string options, adds them as answers, and returns the selected option's string.
function utility_unknown_1035(P0)
    local var_0000

    save_answers()
    var_0000 = add_answer(P0)
    restore_answers()
    return var_0000
end