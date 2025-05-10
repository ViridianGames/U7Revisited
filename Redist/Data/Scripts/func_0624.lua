--- Best guess: Retrieves a bedroll, adjusting game state and inventory, with conditional item placement based on eventid.
function func_0624(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        unknown_007EH() --- Guess: Clears game state
        var_0000 = {1, 1, 1, 0, 0, 0, -1, -1, -1}
        var_0001 = {-1, 0, 1, -1, 0, 1, -1, 0, 1}
        destroy_item(356) --- Guess: Destroys item
        set_object_quality(itemref, 7) --- Guess: Sets item property
        unknown_008BH(2, itemref, 1572) --- Guess: Sets item event
        var_0002 = add_container_items(356, {8033, 1, 17447, 17516, 17456, 7769})
        if var_0002 then
            var_0002 = add_container_items(356, {1572, 8021, 2, 7719})
        end
    elseif eventid == 2 then
        set_item_type(itemref, 583) --- Guess: Sets item type
        set_item_frame(itemref, 0)
    elseif eventid == 7 then
        unknown_007EH() --- Guess: Clears game state
        var_0002 = add_container_items(356, {7763, 1, 17447, 17516, 17456, 7769})
        if not var_0002 then
            var_0002 = add_container_items(356, {1572, 8021, 2, 7719})
        end
    end
end