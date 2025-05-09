--- Best guess: Removes items from a golem’s body, likely cleaning up inventory after a quest or event.
function func_08E6(var_0000)
    local var_0001, var_0002, var_0003, var_0004

    while true do
        var_0001 = unknown_002AH(359, 359, 359, var_0000)
        if var_0001 then
            for _, var_0004 in ipairs(var_0001) do
                unknown_006FH(var_0004)
            end
        else
            break
        end
    end
    unknown_006FH(var_0000)
    return
end