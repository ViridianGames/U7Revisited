--- Best guess: Creates a new array from an input array, excluding a specified element.
function utility_unknown_1084(P0, P1)
    local var_0000

    var_0000 = {}
    for var_0001 in ipairs(P0) do
        if var_0002 ~= P1 then
            table.insert(var_0000, var_0002)
        end
    end
    return var_0000
end