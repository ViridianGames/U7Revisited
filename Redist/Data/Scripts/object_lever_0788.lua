--- Best guess: Manages a lever or switch, toggling its frame and applying effects to nearby items (e.g., IDs 870, 515) if quality matches.
function object_lever_0788(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        close_gumps()
        var_0000 = -1
        var_0001 = -1
        var_0002 = -3
        utility_position_0808(7, objectref, 788, var_0002, var_0001, var_0000, objectref)
    elseif eventid == 7 or eventid == 2 then
        if eventid ~= 2 then
            var_0003 = utility_unknown_0807(objectref, -356)
            var_0004 = execute_usecode_array({17505, 17511, 8449, var_0003, 7769}, -356)
        end
        var_0005 = get_object_frame(objectref)
        if var_0005 % 2 == 0 then
            get_object_frame(var_0005 + 1, objectref)
        else
            get_object_frame(var_0005 - 1, objectref)
        end
        set_object_quality(objectref, 28)
        var_0006 = _get_object_quality(objectref)
        var_0007 = find_nearby(0, 15, 870, objectref)
        var_0008 = find_nearby(0, 15, 515, objectref)
        var_0007 = table.concat({var_0007, var_0008})
        var_0008 = {}
        for var_0009 in ipairs(var_0007) do
            if _get_object_quality(var_000B) == var_0006 then
                table.insert(var_0008, var_000B)
            end
        end
        var_0004 = utility_unknown_0782(var_0008)
        utility_unknown_0822(-359, objectref)
    end
end