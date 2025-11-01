--- Best guess: Generates noun pairs (e.g., "batting cage" or "batting cages"), likely for item or concept references.
function utility_unknown_0870(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = {
        {"batting cage", "*"},
        {"flagstaff", "*"},
        {"digit", "*"},
        {"nail", "*"},
        {"epaphite", "*"},
        {"sycophant", "*"},
        {"demagouge", "*"},
        {"prophet", "profit"},
        {"pus", "pus"},
        {"mulch", "mulch"},
        {"Garden Gnome", "*"},
        {"personal crisis", "personal crises"},
        {"wit", "*"},
        {"bathysphere", "*"},
        {"jello-flavoring", "*"},
        {"origami ball", "*"},
        {"communion wafer", "*"},
        {"armageddon", "*"},
        {"baloon payment", "*"}
    }
    var_0001 = random(1, math.floor(array_size(var_0000) / 2)) --- Guess: Generates random index
    var_0002 = var_0000[var_0001 * 2 - 1][1]
    var_0003 = var_0000[var_0001 * 2][1]
    if var_0003 == "*" then
        var_0003 = var_0002 .. "s"
    end
    return {var_0002, var_0003}
end