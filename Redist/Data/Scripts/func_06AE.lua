--- Best guess: Applies an effect to NPC ID 149 via an external function (ID 1173) when event ID 3 is triggered, likely part of a dungeon trap.
function func_06AE(eventid, objectref)
    if eventid == 3 then
        unknown_0495H(unknown_001BH(149))
    end
    return
end