--- Best guess: Handles a storm cloak interaction, moving it to specific coordinates or displaying an error if used indoors.
function func_0149(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if not unknown_0079H(objectref) then
        return
    end
    if eventid == 1 then
        var_0000 = unknown_006EH(objectref)
        if not var_0000 then
            var_0001 = unknown_0018H(-356)
            var_0001[1] = var_0001[1] + 1
            var_0002 = unknown_0025H(objectref)
            if not var_0002 then
                var_0002 = unknown_0026H(var_0001)
            end
        end
        if not unknown_0081H() then
            unknown_007EH()
        end
        var_0003 = -1
        var_0004 = -1
        var_0005 = -2
        unknown_0828H(7, objectref, 329, var_0005, {var_0004, var_0003})
    elseif eventid == 7 then
        if not unknown_0062H() then
            var_0002 = unknown_0001H({0, 14, -1, 17419, 8015, 3, -3, 17419, 8013, 2, 7975, 3, -1, 17419, 8016, 5, 7975, 14, -1, 17419, 8013, 0, 7750}, objectref)
            var_0002 = unknown_0001H({7, -6, 7947, 2, 17447, 8033, 2, 17447, 8037, 6, 17497, 17505, 7788}, -356)
        else
            unknown_08FEH("@Try it outside!@")
        end
    end
end