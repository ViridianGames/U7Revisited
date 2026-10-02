--- Best guess: Applies a game effect or status (ID 991) to an entity (ID -356), triggering external functions (0837H, 0838H) if successful, likely for a specific event or interaction.
function utility_event_0395(eventid, objectref)
    local var_0000, var_0001

    var_0000 = find_nearest(5, 991, get_npc_name(-356))
    if not var_0000 then
        var_0001 = utility_position_0823(1, 0, 0, var_0000, objectref)
        utility_event_0824(objectref)
    end
end