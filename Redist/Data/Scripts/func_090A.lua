--- Best guess: Prompts the user with a Yes/No choice, returning true for “Yes” and false for “No”.
function func_090A()
    local var_0000

    save_answers()
    while true do
        var_0000 = add_answer({"No", "Yes"})
        if var_0000 == "Yes" then
            restore_answers()
            return true
        elseif var_0000 == "No" then
            restore_answers()
            return false
        end
    end
end