require "U7LuaFuncs"
-- Function 06CA: Applies NPC effects for Minoc or dungeon
function func_06CA(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 3 then
        return
    end

    local0 = {-92, -86, -87}
    for _, local3 in ipairs(local0) do
        call_093FH(11, local3)
    end

    return
end