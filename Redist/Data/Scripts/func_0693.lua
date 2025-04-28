require "U7LuaFuncs"
-- Function 0693: Move player to specific position
function func_0693(eventid, itemref)
    local local0, local1, local2

    local0 = get_item_position(itemref)
    move_object(-1, 0, 0, 0, local0[2] - 3, local0[1], 9)
    call_000FH(46)
end