--- Best guess: Generates verb conjugations (e.g., "collate", "collating"), possibly for event triggers.
function utility_event_0873(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = {
        {"collate", "collated", "collating"},
        {"sear", "*", "*"},
        {"croak", "*", "*"},
        {"power-nap", "power-napped", "power-napping"},
        {"network", "*", "*"},
        {"conjure", "conjured", "conjuring"},
        {"campaign", "*", "*"},
        {"protest", "*", "*"},
        {"spew", "*", "*"},
        {"inhabit", "*", "*"},
        {"censor", "*", "*"},
        {"lay off", "laid off", "laying off"},
        {"irradiate", "irradiated", "irradiating"},
        {"martinize", "martinized", "martinizing"}
    }
    var_0001 = random(1, math.floor(array_size(var_0000) / 3)) --- Guess: Generates random index
    var_0002 = var_0000[var_0001 * 3 - 2][1]
    var_0003 = var_0000[var_0001 * 3 - 1][1]
    var_0004 = var_0000[var_0001 * 3][1]
    if var_0003 == "*" then
        var_0003 = var_0002 .. "ed"
    end
    if var_0004 == "*" then
        var_0004 = var_0002 .. "ing"
    end
    return {var_0002, var_0003, var_0004}
end