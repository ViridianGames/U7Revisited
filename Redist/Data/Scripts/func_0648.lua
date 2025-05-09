--- Best guess: Implements the create food spell (In Mani Ylem), generating food items for party members.
function func_0648(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        destroy_item(itemref)
        bark(itemref, "@In Mani Ylem@")
        if check_spell_requirements() then
            var_0000 = add_container_items(itemref, {1608, 17493, 17511, 17509, 8038, 68, 7768})
        else
            var_0000 = add_container_items(itemref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        var_0001 = get_party_members()
        -- Guess: sloop generates food for party members
        for i = 1, 5 do
            var_0004 = {2, 3, 4, 1, 72}[i]
            var_0005 = unknown_0018H(var_0004) --- Guess: Gets position data
            var_0006 = get_item_status(377) --- Guess: Gets item status
            if var_0006 then
                var_0007 = random(1, 30)
                set_item_frame(var_0006, var_0007)
                set_item_flag(var_0006, 18)
                var_0000 = unknown_0026H(var_0005) --- Guess: Updates position
            end
        end
    end
end