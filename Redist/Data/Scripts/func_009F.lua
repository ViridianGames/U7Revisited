--- Best guess: Displays the current time in 12-hour format with AM/PM, adjusting for midnight and formatting minutes, likely for a clock or time display item.
function func_009F(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = unknown_0038H()
        var_0001 = "am"
        if var_0000 > 12 then
            var_0000 = var_0000 - 12
            var_0001 = "pm"
        elseif var_0000 == 0 then
            var_0000 = 12
            var_0001 = "am"
        end
        var_0002 = unknown_0039H()
        if var_0002 <= 9 then
            var_0002 = "0" .. var_0002
        end
        var_0003 = " " .. var_0000 .. ":" .. var_0002 .. var_0001
        if unknown_0081H() then
            unknown_007FH(var_0003, objectref)
        else
            unknown_0040H(var_0003, objectref)
        end
    end
    return
end