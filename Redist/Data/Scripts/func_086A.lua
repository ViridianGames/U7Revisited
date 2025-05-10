--- Best guess: Generates a random humorous phrase from a predefined list, likely for NPC dialogue or a comedic effect.
function func_086A()
    local var_0000, var_0001, var_0002

    var_0000 = {"between the sheets", "with a melon", "assuredly", "above your house", "below the ground"}
    table.insert(var_0000, {"with much consternation", "Gumpily", "fiscally", "similarilly", "throughout the universe"})
    var_0001 = random2(array_size(var_0000), 1)
    var_0002 = var_0000[var_0001]
    return var_0002
end