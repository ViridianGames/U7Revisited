--- Best guess: Manages a quest item, triggering specific effects when used in a particular state (frame 3), setting a flag for quest progression.
function func_0350(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(itemref)
        if var_0000 == 3 then
            var_0001 = unknown_0001H({1782, 8021, 2, 7975, 4, -3, 7947, 4, 17447, 17486, 7937, 67, 7768}, itemref)
        end
    elseif eventid == 2 then
        set_flag(815, true)
        unknown_06F6H(itemref)
    end
end