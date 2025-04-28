require "U7LuaFuncs"
-- Prompts for an answer from a provided list and returns the selected answer.
function func_090B(p0)
    local local1

    save_answers() -- Unmapped intrinsic
    add_answer(p0) -- Unmapped intrinsic
    local1 = external_000AH() -- Unmapped intrinsic
    restore_answers() -- Unmapped intrinsic
    return local1
end