-- Generates a random animal name and plural form for mad-libs style dialogue.
function func_086C()
    local local0, local1, local2, local3

    local0 = {"armadillo", "*", "octopus", "octopi", "ungulate", "*", "cockatoo", "*", "ferret", "*", "weasel", "*", "bassalope", "*", "platypus", "platypuses", "no-see-um", "*", "alpaca", "*", "mooncow", "*", "thundermoose", "*", "llama", "*", "iguana", "*", "reptile", "*", "amphibian", "*", "mammal", "*", "invertebrate", "*"}
    local1 = math.floor(get_random(1, #local0 / 2))
    local2 = local0[local1 * 2 - 1]
    local3 = local0[local1 * 2]
    if local3 == "*" then
        local3 = local2 .. "s"
    end
    return {local3, local2}
end