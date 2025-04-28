require "U7LuaFuncs"
-- Function 0867: Random adjective pair
function func_0867(eventid, itemref)
    local local0, local1, local2, local3

    local0 = {
        "constipated", "fractal", "dysfuctional", "dyslexic", "diurectic", "glandular",
        "hormonal", "obtuse", "obese", "partisan", "bilateral", "symmetrical",
        "frontal", "superfluous", "super-saturated", "molar", "low-pressure", "diagnostic",
        "acidic", "empirical", "basic", "suicidal", "comforting", "passive",
        "hedonisitic", "pagan", "philanthropic", "operatic", "staged", "affected",
        "grotesque", "orgasmic", "organic", "pedantic", "imperialist", "Gumpy",
        "co-dependent"
    }
    local1 = _ArraySize(local0)
    local1 = _Random2(local1, 1)
    local2 = local0[local1]
    local1 = _Random2(local1, 1)
    local3 = local0[local1]
    set_return({local3, local2})
end