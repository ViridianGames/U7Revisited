--- Best guess: Manages barge or ferry movement, checking ownership and NPC presence (e.g., ferryman).
function func_0634(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_item_owner(itemref) --- Guess: Gets item owner
    if not var_0000 then
        var_0001 = get_item_type(itemref) --- Guess: Gets item type
        if var_0001 == 840 then
            unknown_0812H(var_0000) --- Guess: Handles barge movement
        elseif var_0001 == 652 then
            calle_028CH(itemref) --- External call to handle specific item
        elseif var_0001 == 199 then
            var_0002 = unknown_0035H(0, 25, 155, 356) --- Guess: Sets NPC location
            if not var_0002 then
                if get_item_owner(var_0002) == var_0000 and unknown_0088H(20, 356) == var_0002 then
                    calle_061CH(var_0000) --- External call to handle ferry
                    unknown_008AH(20, 356) --- Guess: Sets quest flag
                end
            else
                var_0003 = unknown_0088H(20, 356)
                if not var_0003 then
                    unknown_0831H(var_0003) --- Guess: Triggers ferry event
                end
            end
        end
    end
end