--- Best guess: Sets flag 0 and triggers an action with value 1000 when event ID 3 is received and flag 0 is not set, likely part of a dungeon trigger.
function func_06A6(eventid, itemref)
    if eventid == 3 and not get_flag(0) then
        unknown_0911H(1000)
        set_flag(0, true)
    end
    return
end