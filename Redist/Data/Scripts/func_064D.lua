--- Best guess: Manages the "In Lor" spell, creating a light source (ID 500) with specific properties, with a fallback effect if the spell fails.
function func_064D(eventid, itemref)
    local var_0000

    if eventid == 1 then
        unknown_005CH(itemref)
        bark(itemref, "@In Lor@")
        if not unknown_0906H() then
            var_0000 = unknown_0001H(itemref, {1613, 17493, 17511, 8037, 68, 17496, 7715})
        else
            var_0000 = unknown_0001H(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        unknown_0057H(500)
    end
end