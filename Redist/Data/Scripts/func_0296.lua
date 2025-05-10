--- Best guess: Simulates fishing, with outcomes ranging from catching a fish to losing bait, based on random chance.
function func_0296(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 or eventid == 4 then
        unknown_007EH()
        var_0000 = object_select_modal()
        var_0001 = unknown_0001H({17505, 7783}, -356)
        if not unknown_0090H({var_0000[2], var_0000[3], var_0000[4]}) then
            unknown_006AH(0)
        end
        var_0002 = unknown_0018H(-356)
        var_0002[1] = var_0002[1] + 1
        var_0003 = false
        var_0004 = 0
        var_0005 = unknown_0035H(0, 15, 509, -356)
        for var_0006 in ipairs(var_0005) do
            var_0004 = var_0004 + 1
        end
        if var_0004 > 0 and random2(10, 1) <= var_0004 then
            var_0003 = true
        end
        if var_0003 then
            var_0008 = unknown_0024H(377)
            if not var_0008 then
                get_object_frame(12, var_0008)
                unknown_0089H(11, var_0008)
                var_0001 = unknown_0026H(var_0002)
                var_0009 = random2(3, 1)
                if var_0009 == 1 then
                    unknown_08FEH("@Indded, a whopper!@")
                    if not unknown_002FH(-2) then
                        unknown_0933H(16, "@I have seen bigger.@", -2)
                    end
                elseif var_0009 == 2 then
                    unknown_08FEH("@What a meal!@")
                elseif var_0009 == 3 then
                    unknown_08FEH({"@That fish does not", "look right.@"})
                end
            end
        else
            var_0009 = random2(4, 1)
            if var_0009 == 1 then
                unknown_0933H(0, "@Not even a bite!@", -356)
            elseif var_0009 == 2 then
                unknown_0933H(0, "@It got away!@", -356)
                if not unknown_002FH(-1) then
                    unknown_0933H(16, "@It was the Big One!@", -1)
                end
            elseif var_0009 == 3 then
                unknown_0933H(0, "@I've lost my bait.@", -356)
            elseif var_0009 == 4 then
                unknown_0933H(0, "@I felt a nibble.@", -356)
            end
        end
    end
end