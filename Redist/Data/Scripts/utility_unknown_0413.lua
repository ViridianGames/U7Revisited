--- Best guess: Manages an interaction mechanic with item ID 718, applying directional effects based on item quality (0-7) and triggering an external function (0828H).
function utility_unknown_0413(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 7 then
        UNKNOWN()
    end

    var_0000 = utility_event_0897()
    if var_0000 then
        var_0000 = remove_item(var_0000)
    end

    var_0001 = false
    var_0002 = false
    var_0003 = find_nearest(10, 718, get_npc_name(-356))
    if not var_0003 then
        var_0004 = utility_unknown_1069(var_0003)
        if var_0004 == 0 or var_0004 == 1 or var_0004 == 7 then
            var_0001 = {-1, 1, 0, 0}
            var_0002 = {0, 0, 1, -1}
        elseif var_0004 == 2 then
            var_0001 = {-1, 0, 0, 1}
            var_0002 = {0, -1, 1, 0}
        elseif var_0004 == 3 or var_0004 == 4 or var_0004 == 5 then
            var_0001 = {-1, 1, 0, 0}
            var_0002 = {0, 0, -1, 1}
        elseif var_0004 == 6 then
            var_0001 = {1, 0, 0, -1}
            var_0002 = {0, -1, 1, 0}
        else
            var_0001 = {-1, 0, 1, 0}
            var_0002 = {0, 1, 0, -1}
        end
    end

    var_0005 = get_npc_name(-356)
    utility_position_0808(7, var_0005, 1693, 0, var_0002, var_0001, var_0005)
end