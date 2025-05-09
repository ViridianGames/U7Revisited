--- Best guess: Implements the summon item spell (Kal Por Ylem), summoning a specific item (type 330) with restrictions.
function func_0662(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = item_select_modal() --- Guess: Selects spell target
        if get_item_type(var_0000) ~= 330 and get_item_owner(356) and not get_flag(39) then
            bark(itemref, "@Kal Por Ylem@")
            var_0001 = add_container_items(var_0000, {1554, 17493, 7715})
            var_0002 = add_container_items(itemref, {17514, 17520, 8047, 67, 7768})
            var_0001 = unknown_0018H(itemref) --- Guess: Gets position data
            apply_sprite_effect(-1, 0, 0, 0, var_0001[2], var_0001[1], 13) --- Guess: Applies sprite effect
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
end