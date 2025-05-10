--- Best guess: Manages the "Vas An Flam" spell, creating fire-related items (e.g., fire pits, IDs 435, 338, 526, 701) at calculated positions, with a fallback effect if the spell fails.
function func_064B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid ~= 1 then
        return
    end

    unknown_005CH(objectref)
    bark(objectref, "@Vas An Flam@")
    if not unknown_0906H() then
        var_0000 = unknown_0001H(objectref, {17511, 17509, 7782})
        var_0001 = 25
        var_0002 = {435, 338, 526, 701}
        for var_0003 in ipairs(var_0002) do
            var_0006 = unknown_0035H(0, var_0001, var_0005, objectref)
            for var_0007 in ipairs(var_0006) do
                var_000A = get_object_shape(var_0009)
                var_000B = unknown_0019H(var_0009, objectref) // 3 + 2
                var_0000 = unknown_0002H(unknown_0095H(var_000A), var_000B, {var_000A, 17493, 7715}, var_0009)
            end
        end
    else
        var_0000 = unknown_0001H(objectref, {1542, 17493, 17511, 17509, 7782})
    end
end