--- Best guess: Searches for an item with frame 12, returning it if found, likely for item filtering.
function utility_unknown_0836()
    local var_0000, var_0001, var_0002, var_0003, var_0004

    -- Guess: sloop searches for item with frame 12
    for i = 1, 5 do
        var_0003 = ({1, 2, 3, 0, 27})[i]
        var_0004 = get_object_frame(var_0003) --- Guess: Gets item frame
        if var_0004 == 12 then
            return var_0003
        end
    end
    return 0
end