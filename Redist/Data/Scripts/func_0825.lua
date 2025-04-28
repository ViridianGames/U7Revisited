require "U7LuaFuncs"
-- Function 0825: Adjust position based on comparison
function func_0825(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if local2[eventid] >= local1[eventid] then
        if eventid == 1 then
            local3 = 4662
            local4 = 4658
        elseif eventid == 2 then
            local3 = 4656
            local4 = 4660
        end
        if local2[eventid] == local1[eventid] then
            local5 = 4
        else
            local5 = 3
        end
    else
        if eventid == 1 then
            local3 = 4658
            local4 = 4662
        elseif eventid == 2 then
            local3 = 4660
            local4 = 4656
        end
        local5 = -3
    end
    local2[eventid] = local2[eventid] + local5
    if _GetNPCProperty(3, -356) > 0 then
        call_0001H({1, 17447, 8045, 3, 17447, 8558, local4, 7769}, -356)
    end
    set_return(local2)
end