--- Best guess: Boosts NPC stats (strength, dexterity, intelligence) when a consumable item is used on them.
function object_venom_0649(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = object_select_modal()
        if not is_npc(var_0000) then
            var_0001 = get_npc_quality(0, var_0000)
            var_0002 = get_npc_quality(1, var_0000)
            var_0003 = get_npc_quality(2, var_0000)
            if var_0001 + 5 > 30 then
                var_0001 = 30
            else
                var_0001 = var_0001 + 5
            end
            if var_0002 + 5 > 30 then
                var_0002 = 30
            else
                var_0002 = var_0002 + 5
            end
            if var_0003 + 5 > 30 then
                var_0003 = 30
            else
                var_0003 = var_0003 + 5
            end
            utility_unknown_0821(var_0001, 0, var_0000)
            utility_unknown_0821(var_0002, 1, var_0000)
            utility_unknown_0821(var_0003, 2, var_0000)
            set_object_quality(objectref, 72)
            var_0004 = execute_usecode_array(var_0000, {71, 8024, 1539, 8021, 1, 17449, 7715})
            remove_item(objectref)
        else
            utility_unknown_1021(60)
        end
    end
end