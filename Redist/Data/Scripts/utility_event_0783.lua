--- Best guess: Clears specific items (IDs 867, 338, 336, 810, 912, 636, 168) within a radius when triggered by event 3.
function utility_event_0783(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid == 3 then
        var_0000 = find_nearby(0, 15, 867, objectref)
        var_0001 = find_nearby(0, 15, 338, objectref)
        var_0002 = find_nearby(0, 15, 336, objectref)
        var_0003 = find_nearby(176, 15, 810, objectref)
        var_0004 = find_nearby(128, 15, 912, objectref)
        var_0005 = find_nearby(0, 15, 636, objectref)
        var_0006 = find_nearby(176, 15, 168, objectref)
        var_0007 = {var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006}
        for var_0008 in ipairs(var_0007) do
            remove_item(var_000A)
        end
    end
end