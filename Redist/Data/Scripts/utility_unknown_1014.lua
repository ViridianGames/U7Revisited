--- Best guess: Calculates a value based on an NPC's property, dividing it by 100 and iteratively halving until below 1, returning the iteration count.
function utility_unknown_1014(var_0000)
    local var_0001, var_0002, var_0003

    var_0001 = get_npc_name(var_0000)
    var_0002 = math.floor(get_npc_prop(8, var_0001) / 100)
    var_0003 = 1
    while var_0002 > 0 do
        var_0003 = var_0003 + 1
        var_0002 = math.floor(var_0002 / 2)
    end
    return var_0003
end