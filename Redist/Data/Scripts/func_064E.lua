--- Best guess: Manages the "In Wis" spell, displaying the player’s coordinates with directional labels (North, South, East, West), with a fallback effect if the spell fails.
function func_064E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        bark(objectref, "@In Wis@")
        if not unknown_0906H() then
            var_0000 = unknown_0001H(objectref, {1614, 8021, 4, 17447, 17519, 17505, 8045, 67, 7768})
        else
            var_0000 = unknown_0001H(objectref, {1542, 17493, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        var_0001 = unknown_0018H(-356)
        var_0002 = (var_0001[1] - 933) // 10
        var_0003 = (var_0001[2] - 1134) // 10
        if var_0002 < 0 then
            var_0004 = " " .. unknown_0932H(var_0002) .. " West"
        else
            var_0004 = " " .. unknown_0932H(var_0002) .. " East"
        end
        if var_0003 < 0 then
            var_0005 = " " .. unknown_0932H(var_0003) .. " North"
        else
            var_0005 = " " .. unknown_0932H(var_0003) .. " South"
        end
        bark(objectref, var_0004 .. var_0005)
    end
end