-- Generates a random phrase for mad-libs style dialogue.
function func_086A()
    local local0, local1, local2

    local0 = {"between the sheets", "with a melon", "assuredly", "above your house", "below the ground", "with much consternation", "Gumpily", "fiscally", "similarilly", "throughout the universe"}
    local1 = get_random(1, #local0)
    local2 = local0[local1]
    return local2
end