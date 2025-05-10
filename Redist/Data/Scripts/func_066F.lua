--- Best guess: Manages the "Vas Zu" spell, putting multiple targets (ID -1) within a radius to sleep, with a fallback effect if the spell fails.
function func_066F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid ~= 1 then
        if eventid == 2 then
            var_0002 = 25
            var_0003 = unknown_0035H(4, var_0002, -1, itemref)
            var_0004 = get_party_members()
            for var_0005 in ipairs(var_0003) do
                if not table.contains(var_0004, var_0007) then
                    unknown_005CH(var_0007)
                    unknown_0089H(1, var_0007)
                end
            end
        end
        return
    end

    unknown_005CH(itemref)
    var_0000 = unknown_0018H(itemref)
    bark(itemref, "@Vas Zu@")
    if not unknown_0906H() then
        unknown_0053H(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7)
        var_0001 = unknown_0001H(itemref, {1647, 17493, 17514, 17511, 17519, 17509, 8033, 65, 7768})
    else
        var_0001 = unknown_0001H(itemref, {1542, 17493, 17514, 17511, 17519, 17509, 7777})
    end
end