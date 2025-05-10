--- Best guess: Sets flag 60 when triggered by event ID 3, likely part of a dungeon forge sequence.
function func_06A4(eventid, objectref)
    if eventid == 3 then
        set_flag(60, true)
    end
    return
end