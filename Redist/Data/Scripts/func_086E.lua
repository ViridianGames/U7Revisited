require "U7LuaFuncs"
-- Generates a random nickname for mad-libs style dialogue.
function func_086E()
    local local0, local1, local2

    local0 = {"studmuffin", "creampuff", "homeboy", "homes", "whitey", "four-eyes", "goofball", "foreskin", "shmuck", "prepuce", "smegma-breath", "Comrade", "badycakes", "smart-guy", "oinker", "smartypants", "Spankamiah"}
    local1 = get_random(1, #local0)
    local2 = local0[local1]
    return local2
end