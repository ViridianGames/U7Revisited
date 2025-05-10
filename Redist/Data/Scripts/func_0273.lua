--- Best guess: Manages a lockpick, unlocking chests or doors with a dexterity check, potentially breaking the pick or triggering traps.
function func_0273(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        var_0000 = object_select_modal()
        set_object_quality(itemref, 27)
        var_0001 = get_object_shape(var_0000)
        var_0002 = _get_object_quality(var_0000)
        var_0003 = get_npc_quality(1, -356) >= random2(30, 1)
        if var_0001 == 522 then
            if var_0002 == 0 and var_0003 then
                set_object_shape(800, var_0000)
                bark("Unlocked", var_0000)
            elseif var_0002 == 255 and var_0003 then
                var_0004 = unknown_0024H(704)
                if not var_0004 then
                    var_0005 = unknown_0026H(unknown_0018H(var_0000))
                    unknown_007EH()
                    var_0005 = unknown_0054H(704, var_0004, var_0004)
                end
                if not var_0003 then
                    set_object_shape(var_0000, 800)
                    bark("Unlocked", var_0000)
                else
                    bark("Pick broke", var_0000)
                    unknown_0925H(itemref)
                end
            else
                bark("Pick broke", var_0000)
                unknown_0925H(itemref)
            end
        else
            var_0006 = {433, 432, 270, 376}
            for var_0007 in ipairs(var_0006) do
                if var_0001 == var_0009 then
                    if var_0002 == 0 then
                        if var_0003 and unknown_081BH(var_0000) == 2 then
                            unknown_081CH(0, var_0000)
                            bark("Unlocked", var_0000)
                        else
                            bark("Pick broke", var_0000)
                            unknown_0925H(itemref)
                        end
                    else
                        unknown_08FEH("@Strange that did not work.@")
                    end
                end
            end
            unknown_08FFH("@Try those on a locked chest or door.@")
        end
    end
end