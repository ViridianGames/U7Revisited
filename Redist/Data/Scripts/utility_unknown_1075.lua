--- Best guess: Checks an item's status via func_0937, then adds items to a container if the condition fails.
function utility_unknown_1075(arg1, arg2, arg3)
    local var_0000, var_0001, var_0002, var_0003

    if not utility_unknown_1079(arg3) then --- External call to func_0937
        var_0003 = delayed_execute_usecode_array(arg1, arg2, {17490, 7715}, get_object_owner(arg3)) --- Guess: Unknown function call
    end
end