--- Best guess: Manages item pickup or interaction, checking container and player ownership, triggering specific actions (type 1581) if conditions are met.
function func_028D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = unknown_006EH(objectref)
        if var_0000 == get_npc_name(-356) then
            unknown_062DH(7, objectref)
        elseif var_0000 then
            var_0001 = unknown_0025H(objectref)
            if var_0001 then
                var_0001 = unknown_0036H(-356)
                if not var_0001 then
                    var_0001 = unknown_0036H(var_0000)
                    unknown_006AH(4)
                else
                    unknown_062DH(7, objectref)
                end
            end
        else
            var_0002 = -1
            var_0003 = -1
            var_0004 = -1
            unknown_0828H(objectref, var_0002, var_0003, var_0004, 1581, objectref, 7)
        end
    end
    return
end