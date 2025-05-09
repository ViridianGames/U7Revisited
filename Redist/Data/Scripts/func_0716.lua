--- Best guess: Initializes ritual state and checks for items, similar to func_0715 but with flag reset.
function func_0716(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    set_flag(806, false)
    var_0000 = unknown_0035H(8, 40, 1015, 356) --- Guess: Sets NPC location
    var_0001 = false
    -- Guess: sloop checks for ritual items
    for i = 1, 5 do
        var_0004 = {2, 3, 4, 0, 53}[i]
        if get_container_items(243, 797, var_0004, 4) then --- Guess: Gets container items
            var_0001 = var_0004
        end
        if get_container_items(244, 797, var_0004, 4) then --- Guess: Gets container items
            var_0001 = var_0004
        end
    end
    if var_0001 then
        set_item_frame(var_0001, 29) --- Guess: Sets item frame
    end
    var_0005 = add_container_items_at(356, {10, 1813, 17493, 7715})
end