--- Best guess: Applies an effect to NPC ID 149 via an external function (ID 1173) when event ID 3 is triggered, likely part of a dungeon trap.
function utility_event_0430(eventid, objectref)
    if eventid == 3 then
        npc_guard_0149(get_npc_name(149))
    end
    return
end