--- Best guess: Manages sword interactions during forging, checking heat (frame 8-12) and position, updating frames or displaying failure messages, with specific event triggers.
function func_029C(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        if unknown_0072H(359, 623, 1, -356) then
            var_0000 = unknown_000EH(3, 991, objectref)
            if var_0000 then
                var_0001 = unknown_0018H(objectref)
                var_0002 = unknown_0018H(var_0000)
                if var_0001[1] == var_0002[1] and var_0001[2] == var_0002[2] and var_0001[3] == var_0002[3] + 1 then
                    var_0003 = unknown_0012H(var_0000)
                    if var_0003 >= 10 and var_0003 <= 12 then
                        unknown_026FH(var_0000)
                    end
                end
            end
        end
        unknown_007EH()
        var_0004 = unknown_0012H(objectref)
        if var_0004 >= 8 and var_0004 <= 15 then
            if not unknown_006EH(objectref) then
                var_0005 = {1, -1, 1, 0}
                var_0006 = {0, 2, 1, 2}
                unknown_0828H(objectref, var_0005, var_0006, -3, 668, objectref, 7)
            else
                var_0007 = unknown_0945H(objectref)
                var_0005 = {1, -1, 1, 0}
                var_0006 = {0, 2, 1, 2}
                unknown_0828H(var_0007, var_0005, var_0006, -3, 668, var_0007, 7)
            end
        end
    elseif eventid == 7 then
        var_0009 = unknown_092DH(objectref)
        var_0008 = unknown_0001H({8033, 3, 17447, 8556, var_0009, 7769}, unknown_001BH(-356))
        var_0008 = unknown_0001H({1815, 8021, 3, 7719}, objectref)
    elseif eventid == 2 then
        var_000A = unknown_002AH(-359, -359, 668, unknown_001BH(-356))
        if var_000A then
            var_000B = unknown_0033H()
            var_000C = unknown_0011H(var_000B)
            if var_000C == 991 and unknown_0012H(var_000B) == 1 then
                unknown_0828H(var_000B, 0, 0, 2, 668, var_000B, 8)
            elseif var_000C == 739 and unknown_0012H(var_000B) >= 4 and unknown_0012H(var_000B) <= 7 then
                unknown_0828H(var_000B, 1, 0, 0, 668, var_000B, 9)
            elseif var_000C == 741 then
                var_0003 = unknown_0012H(var_000A)
                if var_0003 >= 8 and var_0003 <= 12 then
                    unknown_0828H(var_000B, 0, 1, 0, 668, var_000B, 10)
                else
                    unknown_0040H("@The sword's not hot.@", unknown_001BH(-356))
                end
            end
        else
            unknown_0040H("@I can't pick it up.@", unknown_001BH(-356))
        end
    elseif eventid == 8 then
        var_0009 = unknown_092DH(objectref)
        var_0008 = unknown_0001H({8033, 3, 17447, 8556, var_0009, 7769}, unknown_001BH(-356))
        var_000A = unknown_002AH(-359, -359, 668, unknown_001BH(-356))
        var_0008 = unknown_0001H({1675, 8021, 3, 7719}, var_000A)
    elseif eventid == 9 then
        var_0009 = unknown_092DH(objectref)
        var_0008 = unknown_0001H({8033, 3, 17447, 8556, var_0009, 7769}, unknown_001BH(-356))
        var_000A = unknown_002AH(-359, -359, 668, unknown_001BH(-356))
        var_0008 = unknown_0001H({1676, 8021, 3, 7719}, var_000A)
    elseif eventid == 10 then
        var_0009 = unknown_092DH(objectref)
        var_0008 = unknown_0001H({8556, var_0009, 7769}, unknown_001BH(-356))
        var_0008 = unknown_0001H({1677, 8021, 5, 7719}, objectref)
    end
    return
end