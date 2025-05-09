--- Best guess: Randomly selects an insult from a list, cycling until a different insult is chosen, used for NPC dialogue or confrontation.
function func_08F1(var_0000)
    local var_0001, var_0002

    var_0001 = {"coward", "toad", "snake", "scoundrel", "wretch", "deceiver", "viper"}
    var_0002 = var_0000
    while var_0002 == var_0000 do
        var_0002 = var_0001[math.random(1, #var_0001)]
    end
    return var_0002
end