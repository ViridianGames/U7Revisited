--- Best guess: Manages portion items, applying various effects (e.g., poisoning, healing) based on frame, with warnings for misuse.
function object_potion_0340(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        utility_unknown_1018(objectref)
        var_0000 = get_object_frame(objectref)
        var_0001 = object_select_modal()
        var_0002 = is_npc(var_0001)
        set_object_quality(objectref, 90)
        if not var_0002 then
            play_sound_effect(68)
            if var_0000 == 0 then
                set_item_flag(1, var_0001)
            elseif var_0000 == 1 then
                var_0003 = random2(12, 3)
                utility_unknown_1066(var_0003, var_0001)
            elseif var_0000 == 2 then
                clear_item_flag(8, var_0001)
                clear_item_flag(7, var_0001)
                clear_item_flag(1, var_0001)
                clear_item_flag(2, var_0001)
                clear_item_flag(3, var_0001)
            elseif var_0000 == 3 then
                set_item_flag(8, var_0001)
            elseif var_0000 == 4 then
                clear_item_flag(1, var_0001)
                if get_npc_number(var_0001) == -150 then
                    set_schedule_type(7, var_0001)
                end
            elseif var_0000 == 5 then
                set_item_flag(9, var_0001)
            elseif var_0000 == 6 then
                cause_light(100)
            elseif var_0000 == 7 then
                set_item_flag(0, var_0001)
            elseif var_0000 >= 8 then
                utility_unknown_1023("@What is this!@")
                abort()
            end
        else
            var_0003 = random2(3, 1)
            if var_0003 == 1 then
                var_0004 = get_lord_or_lady()
                var_0005 = "@Those are expensive, " .. var_0004 .. "! Plese waste them not!@"
                utility_unknown_1023(var_0005)
            else
                utility_unknown_1021(60)
            end
        end
        utility_unknown_1061(objectref)
    end
end