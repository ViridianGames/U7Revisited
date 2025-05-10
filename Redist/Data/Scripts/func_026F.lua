--- Best guess: Manages sword forging by hammering, checking heat levels (frame 8-15) and transforming the sword (type 991) if conditions are met, with failure messages.
function func_026F(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        if not unknown_0072H(359, 623, 1, 356) then
            unknown_006AH(2)
        end
        unknown_007EH()
        unknown_0690H(objectref)
    elseif eventid == 2 then
        var_0000 = false
        var_0001 = unknown_0011H(objectref)
        if var_0001 == 991 then
            var_0000 = unknown_000EH(1, 668, objectref)
        elseif var_0001 == 623 then
            var_0000 = unknown_0033H()
        end
        if var_0000 and unknown_0011H(var_0000) == 668 then
            var_0002 = unknown_000EH(3, 991, var_0000)
            if not var_0002 then
                var_0003 = unknown_0018H(var_0002)
                var_0004 = unknown_0018H(var_0000)
                if var_0004[1] == var_0003[1] and var_0004[2] == var_0003[2] and var_0004[3] == var_0003[3] - 1 then
                    var_0005 = unknown_0012H(var_0000)
                    if var_0005 >= 8 and var_0005 <= 15 then
                        unknown_0828H(var_0000, 0, 2, 0, 623, var_0002, 7)
                    end
                end
            end
        end
    elseif eventid == 7 then
        var_0006 = unknown_000EH(3, 668, unknown_001BH(-356))
        var_0005 = unknown_0012H(var_0006)
        var_0007 = unknown_001BH(-356)
        var_0008 = unknown_092DH(objectref)
        if var_0005 >= 13 and var_0005 <= 15 then
            unknown_0040H("@The sword is not heated.@", var_0007)
            var_0009 = unknown_0001H(var_0008, 7769, var_0007)
        elseif var_0005 == 8 or var_0005 == 9 then
            unknown_0040H("@The sword is too cool.@", var_0007)
            var_0009 = unknown_0001H(var_0008, 7769, var_0007)
        elseif var_0005 >= 10 and var_0005 <= 12 then
            var_0009 = unknown_0001H({17505, 17508, 17511, 17509, 8548, var_0008, 7769}, var_0007)
            var_0002 = unknown_000EH(3, 991, unknown_001BH(-356))
            var_0009 = unknown_0001H({1681, 8021, 4, 7719}, var_0002)
        end
    end
    return
end