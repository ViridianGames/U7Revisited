--- Best guess: Displays the player's coordinates as a compass direction (e.g., "North East"), failing if under a roof, likely for navigation.
function object_sextant_0650(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = get_object_position(-356)
        var_0001 = math.floor((var_0000[1] - 933) / 10)
        var_0002 = math.floor((var_0000[2] - 1134) / 10)
        if var_0001 < 0 then
            var_0003 = " " .. utility_unknown_1074(var_0001) .. " West"
        else
            var_0003 = " " .. utility_unknown_1074(var_0001) .. " East"
        end
        if var_0002 < 0 then
            var_0004 = " " .. utility_unknown_1074(var_0002) .. " North"
        else
            var_0004 = " " .. utility_unknown_1074(var_0002) .. " South"
        end
        if not is_pc_inside() then
            item_say(var_0004 .. var_0003, objectref)
        elseif utility_unknown_1079(-1) then
            item_say("@'Twill not function under a roof!@", -1)
        end
    end
    return
end