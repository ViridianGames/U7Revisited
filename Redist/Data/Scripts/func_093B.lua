--- Best guess: Adjusts an NPC’s property by subtracting a value, capping at the maximum or a calculated threshold.
function func_093B(P0, P1, P2, P3)
    local var_0000, var_0001, var_0002

    var_0000 = _GetNPCProperty(P2, P3)
    var_0001 = var_0000 + P0 * 2
    if var_0001 > _GetNPCProperty(P1, P3) then
        var_0001 = _GetNPCProperty(P1, P3)
    end
    var_0002 = _SetNPCProperty(var_0001 - var_0000, P2, P3)
end