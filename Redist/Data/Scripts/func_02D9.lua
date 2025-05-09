--- Best guess: Updates an object’s state based on quality, possibly for a dynamic environmental effect or puzzle.
function func_02D9(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        unknown_007EH()
        var_0000 = get_object_quality(itemref)
        if var_0000 == 0 or var_0000 > 7 then
            -- call [0000] (0940H, unmapped)
            unknown_0940H(25)
            return
        end
        if var_0000 == 1 then
            if get_flag(343) ~= true then
                var_0001 = {3, 2416, 2690}
            else
                var_0001 = {3, 2464, 2690}
            end
        elseif var_0000 == 2 then
            var_0001 = {3, 1149, 911}
        elseif var_0000 == 3 then
            var_0001 = {3, 2597, 2600}
        elseif var_0000 == 4 then
            var_0001 = {3, 215, 2807}
        elseif var_0000 == 5 then
            var_0001 = {3, 1344, 159}
        elseif var_0000 == 6 then
            var_0001 = {3, 1907, 1545}
        elseif var_0000 == 7 then
            var_0001 = {3, 1431, 2344}
        elseif var_0000 == 255 then
            return
        end
        -- calli 004F, 1 (unmapped)
        unknown_004FH(var_0001)
    end
    return
end