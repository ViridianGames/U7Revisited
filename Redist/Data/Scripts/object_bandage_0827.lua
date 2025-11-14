--- Best guess: Applies bandages to NPCs, checking health status and displaying healing messages or rejection if unnecessary or invalid.
function object_bandage_0827(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = click_on_item()
        if not is_npc(var_0000) then
            utility_unknown_1022("@Do not soil the bandages.@", objectref)
        else
            var_0001 = get_npc_property(0, var_0000)
            var_0002 = get_npc_property(3, var_0000)
            if var_0002 == var_0001 then
                utility_unknown_1023("@It does not appear as though a bandage is needed.@", objectref)
            else
                if var_0000 == get_npc_name(-356) then
                    utility_unknown_1022("@Much better.@", objectref)
                elseif utility_unknown_1079(var_0000) then
                    var_0003 = math.random(1, 3)
                    if var_0003 == 1 then
                        item_say("@Ah, much better!@", var_0000)
                    elseif var_0003 == 2 then
                        item_say("@Thank thee!@", var_0000)
                    elseif var_0003 == 3 then
                        item_say("@That looks better.@", var_0000)
                    end
                end
                var_0003 = math.random(1, 4)
                if var_0002 + var_0003 > var_0001 then
                    var_0003 = var_0001 - var_0002
                end
                var_0003 = set_npc_prop(var_0003, 3, var_0000)
                utility_unknown_1061(objectref)
            end
        end
    end
    return
end