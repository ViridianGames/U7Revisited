require "U7LuaFuncs"
-- Function 0869: Random verb forms
function func_0869(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = {
        "collate", "collated", "collating",
        "sear", "*", "*",
        "croak", "*", "*",
        "power-nap", "power-napped", "power-napping",
        "network", "*", "*",
        "conjure", "conjured", "conjuring",
        "campaign", "*", "*",
        "protest", "*", "*",
        "spew", "*", "*",
        "inhabit", "*", "*",
        "censor", "*", "*",
        "lay off", "laid off", "laying off",
        "irradiate", "irradiated", "irradiating",
        "martinize", "martinized", "martinizing"
    }
    local1 = _ArraySize(local0) / 3
    local1 = _Random2(local1, 1)
    local2 = local0[local1 * 3 - 2]
    local3 = local0[local1 * 3 - 1]
    local4 = local0[local1 * 3]
    if local3 == "*" then
        local3 = local2 .. "ed"
    end
    if local4 == "*" then
        local4 = local2 .. "ing"
    end
    set_return({local4, local3, local2})
end