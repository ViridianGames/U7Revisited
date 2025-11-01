--- Best guess: Applies status effects to party members with sufficient mana, updating their properties and transforming specific items in a radius.
function utility_unknown_1082(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    var_0000 = get_party_list2()
    for var_0001 in ipairs(var_0000) do
        if get_npc_quality(9, var_0002) >= 10 then
            if var_0002 ~= get_npc_name(-356) then
                clear_item_flag(1, var_0002)
            end
            clear_item_flag(8, var_0002)
            clear_item_flag(7, var_0002)
            clear_item_flag(3, var_0002)
            clear_item_flag(2, var_0002)
            clear_item_flag(0, var_0002)
            clear_item_flag(9, var_0002)
            func_093B(P1, 0, 3, var_0002)
            func_093B(P1 * -1, 6, 5, var_0002)
            var_0003 = set_npc_quality(P1 * -1, 9, var_0002)
        end
    end
    var_0004 = find_nearby(0, 30, 701, P0)
    var_0005 = table.insert(var_0004, find_nearby(0, 30, 338, P0))
    for var_0006 in ipairs(var_0005) do
        var_0007 = _get_object_quality(var_0008)
        if var_0007 < P1 * 30 then
            halt_scheduled(var_0008)
            var_0009 = get_object_shape(var_0008)
            if var_0009 == 338 then
                set_object_shape(997, var_0008)
            elseif var_0009 == 701 then
                set_object_shape(595, var_0008)
            end
            var_0003 = set_item_quality(255, var_0008)
        else
            var_0003 = set_item_quality(var_0007 - P1 * 30, var_0008)
        end
    end
end