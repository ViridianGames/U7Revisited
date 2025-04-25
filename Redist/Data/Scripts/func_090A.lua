-- Prompts for a yes/no answer and returns a boolean.
function func_090A()
    save_answers() -- Unmapped intrinsic
    add_answer({"No", "Yes"}) -- Unmapped intrinsic
    while true do
        local answer = get_answer() -- Unmapped intrinsic
        if answer == "Yes" then
            restore_answers() -- Unmapped intrinsic
            return true
        elseif answer == "No" then
            restore_answers() -- Unmapped intrinsic
            return false
        end
    end
end