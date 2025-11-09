--- Best guess: Manages an item interaction, selecting a target and applying an effect with specific parameters.
function object_lightningwand_0629(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = object_select_modal()
    else
        var_0000 = objectref
    end
    var_0001 = execute_usecode_array({17508, 17530, 17514, 17512, 17508, 7715}, -356)
    var_0001 = set_to_attack(629, var_0000, -356)
end