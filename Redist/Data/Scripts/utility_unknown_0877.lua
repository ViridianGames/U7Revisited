--- Best guess: Generates a random singular/plural noun pair from a list of biological, cultural, and humorous terms, appending "s" to the singular form if the plural is "*".
function utility_unknown_0877()
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = {
        "dicot", "*",
        "conifer", "*",
        "slug", "*",
        "sloth", "*",
        "mole-person", "mole-people",
        "pod-person", "pod-people",
        "Canadian", "*",
        "Dominican", "*",
        "Basque", "*",
        "Gypsy", "Gypsies",
        "Serb", "*",
        "Croat", "*",
        "Mongol", "*",
        "Slav", "*",
        "Hindu", "*",
        "Christian", "*",
        "Christian Scientist", "*",
        "cephalopod", "*",
        "rock critic", "*"
    }
    var_0001 = random(1, array_size(var_0000) / 2) --- Guess: Selects random index
    var_0002 = var_0000[(var_0001 * 2) - 1] --- Guess: Gets singular form
    var_0003 = var_0000[var_0001 * 2] --- Guess: Gets plural form
    if var_0003 == "*" then
        var_0003 = var_0002 .. "s" --- Guess: Appends "s" for plural
    end
    return {var_0002, var_0003} --- Guess: Returns singular/plural pair
end