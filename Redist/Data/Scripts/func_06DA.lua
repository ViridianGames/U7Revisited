--- Best guess: Triggers an effect with parameter 359 when event ID 3 is received, likely part of a dungeon or trap sequence.
function func_06DA(eventid, objectref)
    if eventid == 3 then
        unknown_0836H(359, objectref)
    end
    return
end