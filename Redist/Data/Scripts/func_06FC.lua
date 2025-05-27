--- Best guess: Manages item selection and positioning for event ID 2, adjusting coordinates and triggering effects, likely part of a forge or combat mechanic.
function func_06FC(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    if eventid == 2 then
        var_0000 = unknown_0033H()
        var_0001 = unknown_0011H(var_0000)
        var_0002 = false
        var_0003 = unknown_0018H(get_npc_name(356))
        if var_0001 == 721 or var_0001 == 989 then
            -- Skip
        elseif not unknown_0031H(var_0000) then
            unknown_005CH(var_0000)
            var_0002 = unknown_0018H(var_0000)
        elseif var_0000 == 0 then
            var_0002[2] = var_0002[2] - 2
            var_0002[3] = var_0002[3] - 2
            var_0002[4] = var_0002[4] - 2
        else
            var_0002 = unknown_0018H(var_0000)
        end
        var_0004 = unknown_0024H(797)
        unknown_0013H(4, var_0004)
        unknown_0089H(18, var_0004)
        var_0005 = unknown_0015H(150, var_0004)
        var_0005 = unknown_0026H(var_0002)
        var_0006 = unknown_092DH(var_0004)
        var_0007 = unknown_0001H({7769, var_0006}, get_npc_name(356))
        if var_0002[1] ~= var_0003[1] then
            if var_0002[1] < var_0003[1] then
                var_0003[1] = var_0003[1] - 1
            else
                var_0003[1] = var_0003[1] + 2
            end
        end
        if var_0002[2] ~= var_0003[2] then
            if var_0002[2] < var_0003[2] then
                var_0003[2] = var_0003[2] - 1
            else
                var_0003[2] = var_0003[2] + 2
            end
        end
        var_0008 = unknown_0024H(895)
        unknown_0013H(0, var_0008)
        unknown_0089H(18, var_0008)
        if not unknown_0085H(0, 721, var_0003) then
            var_0005 = unknown_0026H(var_0003)
        elseif not unknown_0085H(0, 721, {var_0003[1], var_0003[2] + 1, var_0003[3]}) then
            var_0005 = unknown_0026H({var_0003[1], var_0003[2] + 1, var_0003[3]})
        elseif not unknown_0085H(0, 721, {var_0003[1], var_0003[2] - 2, var_0003[3]}) then
            var_0005 = unknown_0026H({var_0003[1], var_0003[2] - 2, var_0003[3]})
        else
            unknown_0053H(-1, 0, 0, 0, var_0003[2], var_0003[1], 9)
            unknown_000FH(46)
            unknown_006FH(var_0004)
        end
        var_0009 = unknown_0002H(9, {17493, 7715, 1800}, var_0008)
        var_0010 = unknown_0001H({1789, 17493, 7715}, var_0008)
    elseif eventid == 1 then
        var_0011 = unknown_0035H(0, 80, 797, get_npc_name(356))
        for i = 1, #var_0011 do
            var_0014 = var_0011[i]
            var_0015 = unknown_0014H(var_0014)
            var_0016 = unknown_0012H(var_0014)
            if var_0015 == 150 and var_0016 == 4 then
                unknown_007EH()
                var_0017 = unknown_0018H(get_npc_name(356))
                unknown_0053H(-1, 0, 0, 0, var_0017[2] - 1, var_0017[1] - 1, 9)
                unknown_000FH(46)
            end
        end
        unknown_007EH()
        var_0018 = unknown_0002H(1, {17493, 7715, 1788}, objectref)
    end
    return
end