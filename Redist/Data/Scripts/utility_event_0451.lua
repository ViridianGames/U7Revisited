--- Best guess: Manages the Minoc murder scene, setting flag 290, managing timers, and triggering effects when event ID 3 is received.
function utility_event_0451(eventid, objectref)
    local var_0000

    if eventid == 3 then
        if not get_flag(290) then
            set_flag(290, true)
            set_timer(5)
            return
        end
        var_0000 = get_timer(5)
        if var_0000 >= 24 then
            utility_event_0783()
            remove_item(objectref)
        end
    end
    return
end