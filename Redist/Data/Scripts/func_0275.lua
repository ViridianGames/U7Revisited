--- Best guess: Manages an item interaction, selecting a target and applying an effect with specific parameters.
function func_0275(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = object_select_modal()
    else
        var_0000 = objectref
    end
    var_0001 = unknown_0001H({17508, 17530, 17514, 17512, 17508, 7715}, -356)
    var_0001 = unknown_0041H(629, var_0000, -356)
end