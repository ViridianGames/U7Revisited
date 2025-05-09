--- Best guess: Searches for nearby items meeting positional and type criteria, processing them with external functions, possibly for inventory or environmental checks.
function func_087E(itemref, arg1, arg2, arg3)
    local var_0004, var_0007, var_0008, var_0009

    var_0004 = find_nearby_items(0, arg2, -1, arg1) --- Guess: Finds nearby items
    for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
        var_0007 = var_0004[i]
        if var_0007 then
            var_0008 = get_item_type(var_0007) --- Guess: Gets item type
            var_0009 = get_position_data(var_0007) --- Guess: Gets position data
            if var_0009[1] <= arg1[1] and var_0009[1] >= arg3[1] and
               var_0009[2] <= arg1[2] and var_0009[2] >= arg3[2] and
               var_0009[3] < 5 and var_0008 ~= 189 then
                if not check_item_flag(var_0007) then --- Guess: Checks item flag
                    calle_087FH(var_0007) --- External call to process item
                else
                    calle_0880H(arg1, var_0007) --- External call to alternative processing
                end
            end
        end
    end
end