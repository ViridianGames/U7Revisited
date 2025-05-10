--- Best guess: Sets flag 1 and triggers an action with value 1000 when event ID 3 is received and flag 1 is not set, likely part of a dungeon trigger.
function func_06A7(eventid, objectref)
    if eventid == 3 and not get_flag(1) then
        unknown_0911H(1000)
        set_flag(1, true)
    end
    return
end