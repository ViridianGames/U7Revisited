--- Best guess: Displays the current time (hour:minute) above a clock object, using a 12-hour format with leading zero for minutes.
function func_00FC(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = get_time_hour()
        if var_0000 > 12 then
            var_0000 = var_0000 - 12
        end
        if var_0000 == 0 then
            var_0000 = 12
        end
        var_0001 = get_time_minute()
        if var_0001 < 10 then
            var_0001 = "0" .. var_0001
        end
        var_0002 = " " .. var_0000 .. ":" .. var_0001
        bark(itemref, var_0002)
    end
    return
end