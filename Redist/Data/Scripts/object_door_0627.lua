--- Best guess: Manages a lockpick, unlocking chests or doors with a dexterity check, potentially breaking the pick or triggering traps.
function object_door_0627(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        var_0000 = object_select_modal()
        set_object_quality(objectref, 27)
        var_0001 = get_object_shape(var_0000)
        var_0002 = get_object_quality(var_0000)
        var_0003 = get_npc_quality(1, -356) >= random2(30, 1)
        if var_0001 == 522 then
            if var_0002 == 0 and var_0003 then
                set_object_shape(800, var_0000)
                bark(var_0000, "Unlocked")
            elseif var_0002 == 255 and var_0003 then
                var_0004 = create_new_object(704)
                if not var_0004 then
                    var_0005 = update_last_created(get_object_position(var_0000))
                    close_gumps()
                    var_0005 = attack_object(704, var_0004, var_0004)
                end
                if not var_0003 then
                    set_object_shape(var_0000, 800)
                    bark(var_0000, "Unlocked")
                else
                    bark(var_0000, "Pick broke")
                    utility_unknown_1061(objectref)
                end
            else
                bark(var_0000, "Pick broke")
                utility_unknown_1061(objectref)
            end
        else
            var_0006 = {433, 432, 270, 376}
            for var_0007 in ipairs(var_0006) do
                if var_0001 == var_0009 then
                    if var_0002 == 0 then
                        if var_0003 and utility_unknown_0795(var_0000) == 2 then
                            utility_unknown_0796(0, var_0000)
                            bark(var_0000, "Unlocked")
                        else
                            bark(var_0000, "Pick broke")
                            utility_unknown_1061(objectref)
                        end
                    else
                        utility_unknown_1022("@Strange that did not work.@")
                    end
                end
            end
            utility_unknown_1023("@Try those on a locked chest or door.@")
        end
    end
end