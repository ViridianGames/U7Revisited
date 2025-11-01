--- Best guess: Checks if all party members are seated (frame 10 or 26), returning true if all are seated, false otherwise.
function utility_unknown_0781()
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = get_party_members()
    for var_0001 in ipairs(var_0000) do
        var_0004 = get_object_frame(var_0003)
        if var_0004 ~= 10 and var_0004 ~= 26 then
            return false
        end
    end
    return true
end