--- Best guess: Manages a diaper item, changing its state (clean, used, dirty) when applied to specific items (e.g., baby, ID 730).
function func_0336(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            var_0001 = object_select_modal()
            var_0002 = get_object_shape(var_0001)
            if var_0002 == 730 or var_0002 == 864 then
                get_object_frame(1, objectref)
            elseif var_0002 == 822 then
                if get_object_frame(var_0001) == 2 then
                    unknown_0925H(objectref)
                end
            else
                unknown_08FEH("@Those are for babies.@")
            end
        elseif var_0000 == 1 then
            var_0001 = object_select_modal()
            if unknown_0031H(var_0001) then
                unknown_001DH(0, var_0001)
                unknown_004BH(7, var_0001)
                unknown_004CH(-356, var_0001)
                unknown_0925H(objectref)
            elseif get_object_shape(var_0001) == 822 then
                if get_object_frame(var_0001) == 2 then
                    unknown_0925H(objectref)
                end
            end
        elseif var_0000 == 2 then
            unknown_08FEH("@That is for dirty diapers.@")
        end
    end
end