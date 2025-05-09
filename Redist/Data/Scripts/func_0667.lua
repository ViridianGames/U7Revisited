--- Best guess: Implements the lock spell (Ex Por), locking specific item types (e.g., doors, chests) with frame adjustments.
function func_0667(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        var_0001 = get_item_type(var_0000)
        var_0002 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_item(itemref)
        var_0003 = {828, 845, 433, 432, 376, 270}
        var_0004 = {376, 270, 433, 432}
        bark(itemref, "@Ex Por@")
        if check_spell_requirements() and not (var_0001 == var_0003[1] or var_0001 == var_0003[2] or ...) then
            var_0005 = get_item_frame(var_0000)
            if (var_0005 + 1) % 4 ~= 0 then
                var_0006 = add_container_items(itemref, {66, 17496, 17511, 17509, 8550, var_0002, 7769})
                var_0006 = add_container_items(var_0000, {6, 1639, 17493, 7715})
            end
        else
            var_0006 = add_container_items(itemref, {1542, 17493, 17511, 17509, 8550, var_0002, 7769})
        end
    elseif eventid == 2 then
        var_0005 = get_item_frame(itemref)
        var_0007 = var_0005 - 3
        set_item_frame(itemref, var_0007) --- Guess: Sets item frame
    end
end