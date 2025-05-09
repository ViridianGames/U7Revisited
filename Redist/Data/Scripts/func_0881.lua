--- Best guess: Searches for items with specific frames (18–21), possibly for event triggers.
function func_0881(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = set_npc_location(0, 0, 854, 356) --- Guess: Sets NPC location
    for _, var_0003 in ipairs({1, 2, 3, 0}) do
        if get_item_frame(var_0003) >= 18 and get_item_frame(var_0003) <= 21 then --- Guess: Gets item frame
            return var_0003
        end
    end
    return 0
end