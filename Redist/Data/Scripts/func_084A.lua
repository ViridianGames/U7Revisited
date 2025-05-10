--- Best guess: Initializes party members with specific items (IDs 411, 403) and positions (IDs 318, 315, 309, 306), placing items in containers.
function func_084A()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    var_0000 = 1
    var_0001 = {411, 411, 411, 411, 403, 403, 403, 403}
    var_0002 = {318, 315, 309, 306, 318, 315, 309, 306}
    var_0003 = {0, 0, 0, 0, 2, 2, 2, 2}
    var_0004 = get_party_members()
    for var_0005 in ipairs(var_0004) do
        var_0008 = var_0001[var_0000]
        table.insert(var_0008, var_0002[var_0000])
        table.insert(var_0008, var_0003[var_0000])
        var_0000 = var_0000 + 1
        var_0009 = get_container_objects(-359, -359, -359, var_0007)
        for var_000A in ipairs(var_0009) do
            var_000D = unknown_0025H(var_000C)
            if not var_000D then
                var_000D = unknown_0026H(var_0008)
            end
        end
    end
end