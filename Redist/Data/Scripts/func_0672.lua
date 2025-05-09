--- Best guess: Implements the fireball storm spell (Kal Flam Grav), spawning multiple fireballs in a grid pattern.
function func_0672(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    if eventid == 1 then
        var_0000 = item_select_modal() --- Guess: Selects spell target
        destroy_item(itemref)
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(itemref, "@Kal Flam Grav@")
        if check_spell_requirements() then
            var_0002 = add_container_items(itemref, {17509, 17511, 8038, 65, 8536, var_0001, 7769})
            var_0003 = {-2, -2, -2, -1, 0, 1, 2, 2, 2, 1, 0, -1}
            var_0004 = {-1, 0, 1, 2, 2, 2, 1, 0, -1, -2, -2, -2}
            var_0005 = 0
            while var_0005 < 12 do
                var_0005 = var_0005 + 1
                var_0006 = var_0000[2] + var_0003[var_0005]
                var_0007 = var_0000[3] + var_0004[var_0005]
                var_0008 = var_0000[4]
                var_0009 = {var_0008, var_0007, var_0006}
                var_000A = var_0009
                if not unknown_0085H(0, 621, var_0009) then
                    var_0009 = var_000A
                end
                var_000B = get_item_status(621) --- Guess: Gets item status
                if var_000B then
                    set_item_flag(var_000B, 18)
                    set_item_flag(var_000B, 0)
                    var_0002 = unknown_0026H(var_0009) --- Guess: Updates position
                    var_0002 = set_npc_property(1, 3, var_000B) --- Guess: Sets NPC property
                    var_0002 = add_container_items(var_000B, {1650, 17493, 7715})
                end
            end
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17509, 17511, 8550, var_0001, 7769})
        end
    elseif eventid == 2 then
        var_0009 = unknown_0018H(itemref) --- Guess: Gets position data
        var_0002 = unknown_0025H(itemref) --- Guess: Checks position
        if var_0002 then
            var_0002 = unknown_0026H(358) --- Guess: Updates position
        end
        var_000B = get_item_status(895) --- Guess: Gets item status
        if var_000B then
            set_item_flag(var_000B, 18)
            var_0002 = unknown_0026H(var_0009) --- Guess: Updates position
            var_000D = 30
            var_000D = var_000D + random(1, 5)
            var_0002 = add_container_items(var_000B, {var_000D, 17453, 7715})
        end
    end
end