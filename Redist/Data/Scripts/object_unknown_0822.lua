--- Best guess: Manages a diaper item, changing its state (clean, used, dirty) when applied to specific items (e.g., baby, ID 730).
function object_unknown_0822(eventid, objectref)
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
                    utility_unknown_1061(objectref)
                end
            else
                utility_unknown_1022("@Those are for babies.@")
            end
        elseif var_0000 == 1 then
            var_0001 = object_select_modal()
            if is_npc(var_0001) then
                set_schedule_type(0, var_0001)
                set_attack_mode(7, var_0001)
                set_oppressor(-356, var_0001)
                utility_unknown_1061(objectref)
            elseif get_object_shape(var_0001) == 822 then
                if get_object_frame(var_0001) == 2 then
                    utility_unknown_1061(objectref)
                end
            end
        elseif var_0000 == 2 then
            utility_unknown_1022("@That is for dirty diapers.@")
        end
    end
end