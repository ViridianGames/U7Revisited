--- Best guess: Manages an item's interaction, likely a switch or lever, toggling its state and applying effects.
function object_lever_0787(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        close_gumps()
        var_0000 = -1
        var_0001 = -1
        var_0002 = -3
        utility_position_0808(7, objectref, 787, var_0002, var_0001, var_0000, objectref)
    elseif eventid == 7 then
        var_0003 = utility_unknown_0807(objectref, -356)
        var_0004 = execute_usecode_array({17505, 17516, 8449, var_0003, 7769}, -356)
        utility_unknown_0790(objectref)
    elseif eventid == 2 then
        utility_unknown_0790(objectref)
    end
end