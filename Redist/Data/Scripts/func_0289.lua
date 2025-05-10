--- Best guess: Boosts NPC stats (strength, dexterity, intelligence) when a consumable item is used on them.
function func_0289(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = object_select_modal()
        if not unknown_0031H(var_0000) then
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
            unknown_0835H(var_0001, 0, var_0000)
            unknown_0835H(var_0002, 1, var_0000)
            unknown_0835H(var_0003, 2, var_0000)
            set_object_quality(objectref, 72)
            var_0004 = unknown_0001H({71, 8024, 1539, 8021, 1, 17449, 7715}, var_0000)
            unknown_006FH(objectref)
        else
            unknown_08FDH(60)
        end
    end
end