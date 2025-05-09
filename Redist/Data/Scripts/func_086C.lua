--- Best guess: Generates a random singular/plural noun pair from a list of animals and biological categories, appending "s" to the singular form if the plural is "*".
function func_086C()
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = {
        "armadillo", "*",
        "octopus", "octopi",
        "ungulate", "*",
        "cockatoo", "*",
        "ferret", "*",
        "weasel", "*",
        "bassalope", "*",
        "platypus", "platypuses",
        "no-see-um", "*",
        "alpaca", "*",
        "mooncow", "*",
        "thundermoose", "*",
        "llama", "*",
        "iguana", "*",
        "reptile", "*",
        "amphibian", "*",
        "mammal", "*",
        "invertebrate", "*"
    }
    var_0001 = random(1, array_size(var_0000) / 2) --- Guess: Selects random index
    var_0002 = var_0000[(var_0001 * 2) - 1] --- Guess: Gets singular form
    var_0003 = var_0000[var_0001 * 2] --- Guess: Gets plural form
    if var_0003 == "*" then
        var_0003 = var_0002 .. "s" --- Guess: Appends "s" for plural
    end
    return {var_0002, var_0003} --- Guess: Returns singular/plural pair
end