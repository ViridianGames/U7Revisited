--- Best guess: Implements the death bolt spell (Corp Por), dealing high damage to a target, with special handling for the Avatar (356).
function func_0679(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 or (eventid == 4 and get_item_owner(itemref) == 356) then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@Corp Por@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(527, var_0000, itemref) --- Guess: Applies spell effect
            var_0002 = add_container_items(itemref, {17530, 17514, 17519, 8048, 65, 17496, 8559, var_0001, 7769})
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17519, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 4 and itemref ~= 356 then
        if not is_item_valid(itemref) then
            var_0003 = get_npc_property(2, 356) --- Guess: Gets NPC property
            var_0004 = get_npc_property(2, itemref) --- Guess: Gets NPC property
        else
            var_0003 = 0
            var_0004 = 1
        end
        var_0005 = unknown_0088H(14, itemref) --- Guess: Checks NPC status
        if var_0003 > var_0004 and var_0005 == false then
            damage_npc(itemref, 127) --- Guess: Damages NPC
            kill_npc(itemref) --- Guess: Kills NPC
        end
    end
end