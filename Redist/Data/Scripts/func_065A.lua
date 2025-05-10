--- Best guess: Manages the "Kal Bet Xen" spell, summoning a creature (ID 517) with a random chance, creating it with specific properties if the spell succeeds, or applying a fallback effect.
function func_065A(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 2 then
            var_0001 = random2(10, 7)
            while var_0001 > 0 do
                var_0001 = var_0001 - 1
                var_0002 = 517
                var_0003 = unknown_0047H(false, var_0002)
            end
        end
        return
    end

    unknown_005CH(objectref)
    bark(objectref, "@Kal Bet Xen@")
    if not unknown_0906H() then
        var_0000 = unknown_0001H(objectref, {1626, 8021, 65, 17496, 17514, 17520, 7791})
    else
        var_0000 = unknown_0001H(objectref, {1542, 17493, 17514, 17520, 7791})
    end
end