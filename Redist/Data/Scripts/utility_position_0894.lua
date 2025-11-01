--- Best guess: Searches for nearby items meeting positional and type criteria, processing them with external functions, possibly for inventory or environmental checks.
function utility_position_0894(objectref, arg1, arg2, arg3)
    local var_0004, var_0007, var_0008, var_0009

    var_0004 = find_nearbyobject_s(0, arg2, -1, arg1) --- Guess: Finds nearby items
    for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
        var_0007 = var_0004[i]
        if var_0007 then
            var_0008 = get_object_type(var_0007) --- Guess: Gets item type
            var_0009 = get_position_data(var_0007) --- Guess: Gets position data
            if var_0009[1] <= arg1[1] and var_0009[1] >= arg3[1] and
               var_0009[2] <= arg1[2] and var_0009[2] >= arg3[2] and
               var_0009[3] < 5 and var_0008 ~= 189 then
                if not check_object_flag(var_0007) then --- Guess: Checks item flag
                    utility_unknown_0895(var_0007) --- External call to process item
                else
                    utility_position_0896(arg1, var_0007) --- External call to alternative processing
                end
            end
        end
    end
end