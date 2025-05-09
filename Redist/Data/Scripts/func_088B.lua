--- Best guess: Triggers a sacrifice event, creating a well item (ID 748), updating NPC states, and setting a flag for quest progression.
function func_088B()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = unknown_0035H(0, 10, 748, -356)
    var_0001 = 15
    var_0002 = -3
    var_0003 = -3
    var_0004 = unknown_0018H(var_0000)
    unknown_0053H(-1, 0, 0, 0, var_0004[2] + var_0003, var_0004[1] + var_0002, 1)
    var_0005 = unknown_0002H(var_0001, {7750}, var_0000)
    unknown_001FH(-147)
    unknown_001DH(15, -147)
    var_0006 = {-145, -146, -140, -144, -142, -143, -147}
    for var_0007 in ipairs(var_0006) do
        unknown_003FH(var_0009)
    end
    set_flag(419, true)
    abort()
end