--- Best guess: Manages the "Vas Uus Sanct" spell, applying a protective effect (ID 109) to party members, with a fallback effect if the spell fails.
function func_065B(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        if eventid == 2 then
            unknown_000FH(109)
            var_0001 = unknown_0018H(itemref)
            unknown_0053H(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
            var_0002 = _GetPartyMembers()
            var_0002 = table.insert(var_0002, -356)
            for var_0003 in ipairs(var_0002) do
                unknown_0089H(9, var_0005)
            end
        end
        return
    end

    bark(itemref, "@Vas Uus Sanct@")
    if not unknown_0906H() then
        unknown_005CH(itemref)
        var_0000 = unknown_0001H(itemref, {1627, 17493, 17514, 17519, 17520, 7791})
    else
        var_0000 = unknown_0001H(itemref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end