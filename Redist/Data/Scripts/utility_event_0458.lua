--- Best guess: Triggers an effect on NPCs (92, 86, 87) when event ID 3 is activated, likely part of a dungeon or Minoc-related sequence.
function utility_event_0458(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        var_0000 = {92, 86, 87}
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            utility_unknown_1087(11, var_0003)
        end
    end
    return
end