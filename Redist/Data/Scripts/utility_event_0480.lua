--- Best guess: Checks flag 4 and triggers effects on nearby items (types 776, 777) when event ID 3 is received, likely part of a dungeon trap.
function utility_event_0480(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        if not get_flag(4) then
            var_0000 = find_nearby(16, 10, 776, objectref)
            var_0000 = {var_0000, unpack(find_nearby(16, 10, 777, objectref))}
            for i = 1, #var_0000 do
                var_0003 = var_0000[i]
                utility_unknown_1061(var_0003)
            end
            utility_unknown_1061(objectref)
        end
    end
    return
end