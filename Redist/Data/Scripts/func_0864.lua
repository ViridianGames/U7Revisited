-- Function 0864: Random item dialogue
function func_0864(eventid, itemref)
    local local0, local1, local2, local3

    local0 = call_001BH(-253)
    local1 = call_001CH(local0)
    local2 = ""
    local3 = _Random2(4, 1)
    if local1 == 11 then
        if local3 == 1 then
            local2 = "@It should not be much longer!@"
        elseif local3 == 2 then
            local2 = "@Love will show the way.@"
        elseif local3 == 3 then
            local2 = "@Me? Thou brought it!@"
        elseif local3 == 4 then
            local2 = "@I am sorry, truly!@"
        end
    end
    bark(local0, local2)
    return
end