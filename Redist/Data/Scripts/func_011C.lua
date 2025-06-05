--- Best guess: Displays the current time on a sundial, showing hours (6 AM to 8 PM) or noon, with a message if the sun is not visible, likely for a time-based puzzle.
function func_011C(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = unknown_0038H()
        if var_0000 >= 6 and var_0000 <= 11 then
            unknown_0040H(" " .. var_0000 .. " o'clock", objectref)
        elseif var_0000 == 12 then
            unknown_0040H("Noon", objectref)
        elseif var_0000 >= 13 and var_0000 <= 20 then
            var_0000 = var_0000 - 12
            unknown_0040H(" " .. var_0000 .. " o'clock", objectref)
        else
            var_0001 = get_player_name()
            unknown_08FFH("@^" .. var_0001 .. ", I believe the key word in sundial is `sun'.@", objectref)
        end
    end
    return
end