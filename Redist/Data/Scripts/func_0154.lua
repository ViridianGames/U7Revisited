--- Best guess: Manages portion items, applying various effects (e.g., poisoning, healing) based on frame, with warnings for misuse.
function func_0154(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        unknown_08FAH(objectref)
        var_0000 = get_object_frame(objectref)
        var_0001 = object_select_modal()
        var_0002 = unknown_0031H(var_0001)
        set_object_quality(objectref, 90)
        if not var_0002 then
            unknown_000FH(68)
            if var_0000 == 0 then
                unknown_0089H(1, var_0001)
            elseif var_0000 == 1 then
                var_0003 = random2(12, 3)
                unknown_092AH(var_0003, var_0001)
            elseif var_0000 == 2 then
                unknown_008AH(8, var_0001)
                unknown_008AH(7, var_0001)
                unknown_008AH(1, var_0001)
                unknown_008AH(2, var_0001)
                unknown_008AH(3, var_0001)
            elseif var_0000 == 3 then
                unknown_0089H(8, var_0001)
            elseif var_0000 == 4 then
                unknown_008AH(1, var_0001)
                if unknown_003AH(var_0001) == -150 then
                    unknown_001DH(7, var_0001)
                end
            elseif var_0000 == 5 then
                unknown_0089H(9, var_0001)
            elseif var_0000 == 6 then
                unknown_0057H(100)
            elseif var_0000 == 7 then
                unknown_0089H(0, var_0001)
            elseif var_0000 >= 8 then
                unknown_08FFH("@What is this!@")
                abort()
            end
        else
            var_0003 = random2(3, 1)
            if var_0003 == 1 then
                var_0004 = get_lord_or_lady()
                var_0005 = "@Those are expensive, " .. var_0004 .. "! Plese waste them not!@"
                unknown_08FFH(var_0005)
            else
                unknown_08FDH(60)
            end
        end
        unknown_0925H(objectref)
    end
end