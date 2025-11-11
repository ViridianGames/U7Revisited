--- Best guess: Similar to func_0275, manages an item interaction with a target selection and effect application, with slight variations.
function object_firewand_0630(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = object_select_modal()
    else
        var_0000 = objectref
    end
    halt_scheduled(-356)
    var_0001 = execute_usecode_array(-356, {17508, 17530, 17514, 17512, 17508, 7715})
    var_0001 = set_to_attack(630, var_0000, -356)
end