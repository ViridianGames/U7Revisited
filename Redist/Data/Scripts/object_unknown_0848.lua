--- Best guess: Manages a quest item, triggering specific effects when used in a particular state (frame 3), setting a flag for quest progression.
function object_unknown_0848(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 3 then
            var_0001 = execute_usecode_array({1782, 8021, 2, 7975, 4, -3, 7947, 4, 17447, 17486, 7937, 67, 7768}, objectref)
        end
    elseif eventid == 2 then
        set_flag(815, true)
        utility_unknown_0502(objectref)
    end
end