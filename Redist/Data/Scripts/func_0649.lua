--- Best guess: Implements the cure poison spell (An Nox), removing poison status from a selected target.
function func_0649(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        destroy_item(itemref)
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@An Nox@")
        if check_spell_requirements() then
            if is_item_valid(var_0000) then
                var_0002 = add_container_items(itemref, {17511, 17509, 8038, 64, 8536, var_0001, 7769})
                var_0002 = add_container_items(var_0000, {6, 1609, 17493, 7715})
            else
                var_0002 = add_container_items(itemref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
            end
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
        end
    elseif eventid == 2 then
        unknown_008AH(8, itemref) --- Guess: Sets quest flag
        unknown_008AH(7, itemref) --- Guess: Sets quest flag
    end
end