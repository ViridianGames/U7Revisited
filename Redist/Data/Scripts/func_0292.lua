--- Best guess: Manages cooking dough into bread on a fire pit (ID 831), with a chance to burn if overcooked.
function func_0292(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 1 or var_0000 == 2 then
            var_0001 = object_select_modal()
            var_0002 = get_object_shape(var_0001)
            if var_0002 == 831 then
                var_0003 = unknown_0025H(objectref)
                if not var_0003 then
                    var_0004 = unknown_0018H(var_0001)
                    var_0004[1] = var_0004[1] - random2(2, 1)
                    var_0004[3] = var_0004[3] + 1
                    var_0003 = unknown_0026H(var_0004)
                    if not var_0003 then
                        var_0003 = unknown_0002H(60, 658, {17493, 7715}, objectref)
                        if random2(2, 1) == 1 then
                            unknown_08FEH("@Do not over cook it!@")
                        end
                    end
                end
            end
        end
    elseif eventid == 2 then
        var_0004 = unknown_0018H(objectref)
        var_0005 = unknown_0035H(0, 2, 831, objectref)
        if #var_0005 > 0 then
            return
        end
        var_0006 = unknown_0024H(377)
        if not var_0006 then
            unknown_0089H(18, var_0006)
            get_object_frame(0, objectref)
            var_0003 = unknown_0026H(var_0004)
            if not var_0003 then
                var_0007 = random2(3, 1)
                if var_0007 == 1 then
                    unknown_08FEH("@I believe the bread is ready.@")
                elseif var_0007 == 2 then
                    unknown_08FEH("@Mmm... Smells good.@")
                end
            end
        end
    end
end