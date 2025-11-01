--- Best guess: Builds an array of items excluding a specified value, likely for filtering purposes.
function utility_unknown_0770(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = {}
    -- Guess: sloop filters items not equal to arg1
    for i = 1, 5 do
        var_0005 = ({3, 4, 5, 0, 24})[i]
        if var_0005 ~= arg1 then
            table.insert(var_0002, var_0005)
        end
    end
    return var_0002
end