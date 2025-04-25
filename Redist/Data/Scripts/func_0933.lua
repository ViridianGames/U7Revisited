-- Function 0933: Conditional follow wall for combat-ready NPC
function func_0933(eventid, itemref)
    local local0

    if not call_0937H(local2) then
        local3 = follow_wall(eventid, itemref, {17490, 7715})
    end
    return
end