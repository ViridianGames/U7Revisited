require "U7LuaFuncs"
-- Wrapper function calling an external function (intrinsic 03B2H) with the item reference, likely for a specific item or NPC action.
function func_050A(eventid, itemref)
    external_03B2(itemref) -- Unmapped intrinsic
    return
end