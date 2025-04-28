require "U7LuaFuncs"
-- Generates a random entity name and plural form for mad-libs style dialogue.
function func_086D()
    local local0, local1, local2, local3

    local0 = {"dicot", "*", "conifer", "*", "slug", "*", "sloth", "*", "mole-person", "mole-people", "pod-person", "pod-people", "Canadian", "*", "Dominican", "*", "Basque", "*", "Gypsy", "Gypsies", "Serb", "*", "Croat", "*", "Mongol", "*", "Slav", "*", "Hindu", "*", "Christian", "*", "Christian Scientist", "*", "cephalopod", "*", "rock critic", "*"}
    local1 = math.floor(get_random(1, #local0 / 2))
    local2 = local0[local1 * 2 - 1]
    local3 = local0[local1 * 2]
    if local3 == "*" then
        local3 = local2 .. "s"
    end
    return {local3, local2}
end