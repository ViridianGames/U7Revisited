--- Best guess: Prompts for a number input, validates it against a range (50 to eventid/2), and creates money items (ID 644) if valid.
function func_084B(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0001 = ask_number(math.floor(eventid / 2), 1, eventid, 0)
    if var_0001 >= 50 and var_0001 >= math.floor(eventid / 2) then
        var_0002 = unknown_002BH(true, -359, -359, 644, var_0001)
        return true
    end
    return false
end