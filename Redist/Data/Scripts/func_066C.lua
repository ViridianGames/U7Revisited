--- Best guess: Manages the "Vas Mani" spell, healing a selected target’s health (ID 64) by restoring their hit points, with a fallback effect if the spell fails.
function func_066C(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    unknown_005CH(var_0000)
    var_0001 = unknown_092DH(var_0000)
    bark(objectref, "@Vas Mani@")
    if not unknown_0906H() then
        var_0002 = unknown_0001H(objectref, {64, 17496, 17511, 17509, 8550, var_0001, 7769})
        if not unknown_0031H(var_0000) then
            var_0003 = get_npc_quality(var_0000, 0)
            var_0004 = get_npc_quality(var_0000, 3)
            var_0005 = set_npc_quality(var_0000, 3, var_0003 - var_0004)
        end
    else
        var_0002 = unknown_0001H(objectref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
    end
end