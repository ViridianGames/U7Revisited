--- Best guess: Handles beer barrel interaction, updating item frames and displaying complaints about wasting beer, with different frame ranges.
function func_0629(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = get_item_status(912) --- Guess: Gets item status
    if var_0000 then
        set_item_flag(var_0000, 18)
        set_item_frame(var_0000, random(20, 23))
        var_0001 = unknown_0018H(itemref) --- Guess: Gets position data
        var_0002 = unknown_0035H(0, 2, 810, itemref) --- Guess: Sets NPC location
        -- Guess: sloop checks NPC positions
        for i = 1, 5 do
            var_0005 = {3, 4, 5, 2, 114}[i]
            var_0006 = unknown_0018H(var_0005) --- Guess: Gets position data
            if var_0006[1] == var_0001[1] + 1 and var_0006[2] == var_0001[2] - 1 and var_0006[3] == var_0001[3] then
                if get_item_frame(var_0005) == 0 then
                    set_item_frame(var_0005, 3)
                    destroy_item(itemref)
                    var_0007 = add_container_items(itemref, {1577, 7765})
                end
            end
        end
        var_0001[1] = var_0001[1] + random(1, 2) - 1
        var_0001[2] = var_0001[2] - random(0, 2)
        var_0007 = unknown_0026H(var_0001) --- Guess: Updates position
        var_0008 = random(1, 2)
        if var_0008 == 1 then
            display_message("@Turn it off!@") --- Guess: Displays message
        elseif var_0008 == 2 then
            display_message("@Thou art wasting it!@") --- Guess: Displays message
        end
        destroy_item(itemref)
        var_0007 = add_container_items(itemref, {1577, 7765})
    end
end