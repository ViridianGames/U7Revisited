--- Best guess: Implements the poison field spell (In Nox Grav), creating a poison field at a target location.
function func_0675(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        destroy_item(itemref)
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@In Nox Grav@")
        if check_spell_requirements() then
            var_0002 = add_container_items(itemref, {17511, 17510, 8037, 110, 8536, var_0001, 7769})
            var_0003 = get_item_status(900) --- Guess: Gets item status
            if var_0003 then
                var_0004 = var_0000[2] + 1
                var_0005 = var_0000[3] + 1
                var_0006 = var_0000[4]
                var_0007 = {var_0006, var_0005, var_0004}
                set_item_flag(var_0003, 18)
                var_0002 = unknown_0026H(var_0007) --- Guess: Updates position
            end
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17511, 17510, 8549, var_0001, 7769})
        end
    end
end