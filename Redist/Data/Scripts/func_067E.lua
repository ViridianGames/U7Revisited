--- Best guess: Manages the "In Vas Por" spell, causing a mass teleport or movement effect (ID 1662) for party members within a radius, with a fallback effect if the spell fails.
function func_067E(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 2 then
            unknown_0089H(12, itemref)
        end
        return
    end

    unknown_005CH(itemref)
    bark(itemref, "@In Vas Por@")
    if not unknown_0906H() then
        var_0000 = unknown_0001H(itemref, {1662, 17493, 17514, 17519, 8048, 64, 17496, 7791})
        var_0001 = unknown_0018H(itemref)
        unknown_0053H(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
        var_0002 = _GetPartyMembers()
        for var_0003 in ipairs(var_0002) do
            var_0006 = unknown_0019H(var_0005, itemref)
            var_0000 = unknown_0002H(var_0006 // 3 + 5, 1662, {17493, 7715}, var_0005)
        end
    else
        var_0000 = unknown_0001H(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end