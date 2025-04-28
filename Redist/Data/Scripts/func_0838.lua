require "U7LuaFuncs"
-- Function 0838: Update item frame
function func_0838(eventid, itemref)
    local local0, local1, local2

    local1 = _GetItemFrame(itemref)
    if local1 == 8 then
        local2 = call_0001H({1679, 8021, 25, 7975, 8, 8006, 2, 7719}, itemref)
    elseif local1 == 9 then
        local2 = call_0001H({1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 2, 7719}, itemref)
    elseif local1 == 10 then
        local2 = call_0001H({1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 2, 7719}, itemref)
    elseif local1 == 11 then
        local2 = call_0001H({1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 25, 7975, 11, 8006, 2, 7719}, itemref)
    elseif local1 == 12 then
        local2 = call_0001H({1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 25, 7975, 11, 8006, 25, 7975, 12, 8006, 2, 7719}, itemref)
    end
end