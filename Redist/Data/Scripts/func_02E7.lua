-- Function 02E7: Dragon reward mechanic
function func_02E7(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        calli_007E()
        local0 = {1, -1, 0}
        local1 = {1, 1, 1}
        local2 = -1
        call_0828H(7, itemref, 743, local2, local1, local0, itemref)
    elseif eventid == 7 then
        local3 = call_0827H(itemref, -356)
        local4 = callis_0001({17505, 17516, 8449, local3, 7769}, -356)
        local5 = _GetNPCProperty(0, -356)
        if local5 >= 0 and local5 < 4 then
            local5 = 0
        elseif local5 >= 4 and local5 < 8 then
            local5 = 1
        elseif local5 >= 8 and local5 < 12 then
            local5 = 2
        elseif local5 >= 12 and local5 < 15 then
            local5 = 3
        elseif local5 >= 15 and local5 < 18 then
            local5 = 4
        elseif local5 >= 18 and local5 < 23 then
            local5 = 5
        elseif local5 >= 23 and local5 < 27 then
            local5 = 6
        elseif local5 >= 27 and local5 < 30 then
            local5 = 7
        elseif local5 >= 30 then
            local5 = 8
        end
        if local5 > 3 then
            local5 = local5 - _Random2(0, 2)
        end
        if local5 == 7 then
            local5 = 6
        end
        if local5 > 7 then
            local4 = callis_0002({local5 - 1, 24, 17496, 7715}, itemref)
            if npc_in_party(44) and call_0937H(-44) then
                local4 = callis_0002(15, {"@Avatar wins a Dragon!@", 17490, 7715}, -44)
                local4 = callis_002C(false, 0, -359, 742, 1)
            end
        end
        local4 = callis_0001({0, 8518, local5, -1, 17419, 8527, local5, -1, 17419, 8013, 4, 8024, 0, 7750}, itemref)
    end

    return
end