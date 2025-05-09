--- Best guess: Checks if four blackrock pieces are correctly placed around a pedestal, likely for a puzzle or quest trigger in Penumbra’s area.
function func_08C9()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015

    var_0000 = unknown_0035H(0, 40, 718, itemref)
    var_0001 = unknown_0035H(0, 40, 914, itemref)
    var_0002 = 0
    for _, var_0005 in ipairs(var_0000) do
        var_0006 = unknown_0018H(var_0005)
        var_0007 = var_0006[1]
        var_0008 = var_0006[2]
        var_0009 = false
        for _, var_0012 in ipairs(var_0001) do
            var_0013 = unknown_0018H(var_0012)
            var_0014 = var_0013[1]
            var_0015 = var_0013[2]
            if not var_0009 and unknown_0932H(var_0014 - var_0007) <= 1 and unknown_0932H(var_0015 - var_0008) <= 1 then
                var_0002 = var_0002 + 1
                unknown_008AH(18, var_0012)
                var_0009 = true
            end
        end
    end
    return var_0002 == 4
end