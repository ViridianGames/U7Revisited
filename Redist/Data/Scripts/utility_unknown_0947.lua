--- Best guess: Manages party member interactions, updating the party list based on item qualities and conditions, likely for quest or dialogue purposes.
function utility_unknown_0947(eventid)
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0001 = 1
    var_0002 = 0
    var_0003 = false
    var_0004 = get_party_list()
    var_0005 = get_barge(eventid)
    var_0006 = find_nearby(0, 30, 292, eventid)
    var_0007 = {}
    var_0008 = {}
    for i = 1, #var_0006 do
        var_0011 = var_0006[i]
        if get_barge(var_0011) == var_0005 then
            if not var_0003 and get_object_quality(var_0011) == 255 then
                sit_down(var_0011, 356)
                var_0004 = utility_unknown_1084(get_npc_name(356), var_0004)
                var_0003 = true
            else
                table.insert(var_0008, get_distance(356, var_0011))
                table.insert(var_0007, var_0011)
            end
        end
    end
    var_0012 = #var_0004
    var_0007 = utility_unknown_1085(var_0007, var_0008)
    for i = 1, #var_0007 do
        var_0011 = var_0007[i]
        if var_0012 >= var_0001 then
            sit_down(var_0011, var_0004[var_0001])
            var_0001 = var_0001 + 1
        else
            return true
        end
    end
    return false
end