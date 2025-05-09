--- Best guess: Manages oven interaction for baking bread, displaying random dialogue about cooking status.
function func_0635(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 3 then
        var_0000 = unknown_0035H(0, 0, 658, itemref) --- Guess: Sets NPC location
        if var_0000 then
            var_0001 = add_container_items(var_0000, {60, 1589, 17493, 7715})
            if random(1, 2) == 1 then
                display_message("@Do not over cook it!@") --- Guess: Displays message
            end
        end
    elseif eventid == 2 then
        var_0002 = unknown_0018H(itemref) --- Guess: Gets position data
        var_0003 = unknown_0035H(0, 2, 831, itemref) --- Guess: Sets NPC location
        if #var_0003 > 0 then
            unknown_006FH(itemref) --- Guess: Unknown object operation
            var_0004 = get_item_status(377) --- Guess: Gets item status
            if var_0004 then
                set_item_flag(var_0004, 18)
                set_item_frame(itemref, 0)
                var_0001 = unknown_0026H(var_0002) --- Guess: Updates position
                var_0005 = random(1, 3)
                if var_0005 == 1 then
                    display_message("@I believe the bread is ready.@") --- Guess: Displays message
                elseif var_0005 == 2 then
                    display_message("@Mmm... Smells good.@") --- Guess: Displays message
                end
            end
        end
    end
end