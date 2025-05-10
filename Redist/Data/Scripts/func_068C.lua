--- Best guess: Applies a game effect or status (ID 739) to an entity (ID -356), triggering external functions (0837H, 0838H) if successful, likely for a specific event or interaction.
function func_068C(eventid, objectref)
    local var_0000, var_0001

    var_0000 = unknown_000EH(5, 739, unknown_001BH(-356))
    if not var_0000 then
        var_0001 = unknown_0837H(2, -1, 0, var_0000, objectref)
        unknown_0838H(objectref)
    end
end