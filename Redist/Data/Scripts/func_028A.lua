--- Best guess: Displays the player's coordinates as a compass direction (e.g., "North East"), failing if under a roof, likely for navigation.
function func_028A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = unknown_0018H(-356)
        var_0001 = math.floor((var_0000[1] - 933) / 10)
        var_0002 = math.floor((var_0000[2] - 1134) / 10)
        if var_0001 < 0 then
            var_0003 = " " .. unknown_0932H(var_0001) .. " West"
        else
            var_0003 = " " .. unknown_0932H(var_0001) .. " East"
        end
        if var_0002 < 0 then
            var_0004 = " " .. unknown_0932H(var_0002) .. " North"
        else
            var_0004 = " " .. unknown_0932H(var_0002) .. " South"
        end
        if not unknown_0062H() then
            unknown_0040H(var_0004 .. var_0003, itemref)
        elseif unknown_0937H(-1) then
            unknown_0040H("@'Twill not function under a roof!@", -1)
        end
    end
    return
end