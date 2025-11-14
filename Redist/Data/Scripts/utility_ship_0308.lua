--- Best guess: Manages barge or ferry movement, checking ownership and NPC presence (e.g., ferryman).
function utility_ship_0308(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_object_owner(objectref) --- Guess: Gets item owner
    if not var_0000 then
        var_0001 = get_object_shape(objectref) --- Guess: Gets item type
        if var_0001 == 840 then
            utility_event_0786(var_0000) --- Guess: Handles barge movement
        elseif var_0001 == 652 then
            object_unknown_0652(objectref) --- External call to handle specific item
        elseif var_0001 == 199 then
            var_0002 = find_nearby(0, 25, 155, 356) --- Guess: Sets NPC location
            if not var_0002 then
                if get_object_owner(var_0002) == var_0000 and get_item_flag(20, 356) == var_0002 then
                    utility_unknown_0284(var_0000) --- External call to handle ferry
                    clear_item_flag(20, 356) --- Guess: Sets quest flag
                end
            else
                var_0003 = get_item_flag(20, 356)
                if not var_0003 then
                    utility_gangplank_0817(var_0003) --- Guess: Triggers ferry event
                end
            end
        end
    end
end