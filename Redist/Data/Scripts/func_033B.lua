--- Best guess: Applies bandages to NPCs, checking health status and displaying healing messages or rejection if unnecessary or invalid.
function func_033B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = unknown_0033H()
        if not unknown_0031H(var_0000) then
            unknown_08FEH("@Do not soil the bandages.@", objectref)
        else
            var_0001 = unknown_0020H(0, var_0000)
            var_0002 = unknown_0020H(3, var_0000)
            if var_0002 == var_0001 then
                unknown_08FFH("@It does not appear as though a bandage is needed.@", objectref)
            else
                if var_0000 == get_npc_name(-356) then
                    unknown_08FEH("@Much better.@", objectref)
                elseif unknown_0937H(var_0000) then
                    var_0003 = math.random(1, 3)
                    if var_0003 == 1 then
                        unknown_0040H("@Ah, much better!@", var_0000)
                    elseif var_0003 == 2 then
                        unknown_0040H("@Thank thee!@", var_0000)
                    elseif var_0003 == 3 then
                        unknown_0040H("@That looks better.@", var_0000)
                    end
                end
                var_0003 = math.random(1, 4)
                if var_0002 + var_0003 > var_0001 then
                    var_0003 = var_0001 - var_0002
                end
                var_0003 = unknown_0021H(var_0003, 3, var_0000)
                unknown_0925H(objectref)
            end
        end
    end
    return
end