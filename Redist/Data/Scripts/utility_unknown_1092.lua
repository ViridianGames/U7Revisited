--- Best guess: Finds the outermost container of an item, ensuring it's not owned by the Avatar (ID 356).
function utility_unknown_1092(eventid, objectref)
    local var_0000, var_0001

    var_0001 = get_object_container(objectref) --- Guess: Gets item container
    while var_0001 and get_object_owner(var_0001) ~= 356 do --- Guess: Gets item owner
        var_0001 = get_object_container(var_0001) --- Guess: Gets item container
        if not var_0001 then
            return 0
        end
    end
    return var_0001
end