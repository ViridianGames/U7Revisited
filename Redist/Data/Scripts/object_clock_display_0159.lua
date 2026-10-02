--- Best guess: Displays the current time in 12-hour format with AM/PM, adjusting for midnight and formatting minutes, likely for a clock or time display item.
function object_unknown_0159(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = game_hour()
        var_0001 = "am"
        if var_0000 > 12 then
            var_0000 = var_0000 - 12
            var_0001 = "pm"
        elseif var_0000 == 0 then
            var_0000 = 12
            var_0001 = "am"
        end
        var_0002 = game_minute()
        if var_0002 <= 9 then
            var_0002 = "0" .. var_0002
        end
        var_0003 = " " .. var_0000 .. ":" .. var_0002 .. var_0001
        if in_gump_mode() then
            item_say(var_0003, objectref)
        else
            item_say(var_0003, objectref)
        end
    end
    return
end