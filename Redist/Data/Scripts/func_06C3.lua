--- Best guess: Manages the Minoc murder scene, setting flag 290, managing timers, and triggering effects when event ID 3 is received.
function func_06C3(eventid, objectref)
    local var_0000

    if eventid == 3 then
        if not get_flag(290) then
            set_flag(290, true)
            unknown_0066H(5)
            return
        end
        var_0000 = unknown_0065H(5)
        if var_0000 >= 24 then
            unknown_080FH()
            unknown_006FH(objectref)
        end
    end
    return
end