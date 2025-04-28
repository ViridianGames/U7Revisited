require "U7LuaFuncs"
-- Function 02DF: Training equipment dialogue
function func_02DF(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid ~= 1 then
        return
    end

    local0 = "@I believe those are for the trainers to use.* If thou art in need of practice, why not seek out a trainer?@"
    call_08FFH(local0)

    return
end