--- Best guess: Manages a container mechanic, checking items within a container (ID -356), applying effects based on container state, and creating items (ID 1803).
function func_070B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if not unknown_0944H(objectref) then
        var_0000 = unknown_0018H(objectref)
        var_0001 = false
        var_0002 = unknown_0025H(objectref)
        var_0003 = get_container_objects(-359, -359, -1, unknown_001BH(-356))
        for var_0004 in ipairs(var_0003) do
            if var_0001 == false and not unknown_08E9H(var_0006) then
                var_0002 = unknown_0025H(var_0006)
                var_0007 = unknown_0018H(unknown_001BH(-356))
                var_0002 = unknown_0026H(var_0007)
            end
            if var_0001 == true and not unknown_08EAH(var_0006) then
                var_0002 = unknown_0025H(var_0006)
                var_0007 = unknown_0018H(unknown_001BH(-356))
                var_0002 = unknown_0026H(var_0007)
            end
            if var_0001 == 2 and unknown_006EH(var_0006) == unknown_001BH(-356) then
                var_0002 = unknown_0025H(var_0006)
                var_0007 = unknown_0018H(unknown_001BH(-356))
                var_0002 = unknown_0026H(var_0007)
            end
        end
        var_0001 = var_0001 + 1
        var_0002 = unknown_0025H(objectref)
    end
    var_0008 = unknown_0001H(objectref, {1803, 17493, 17443, 7724})
end