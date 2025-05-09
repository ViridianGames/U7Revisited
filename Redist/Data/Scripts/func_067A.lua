--- Best guess: Manages the "Tym Vas Flam" spell, igniting a target (ID 621) with a fiery effect, applying status effects and creating visual items, with a fallback effect if the spell fails.
function func_067A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = false
    if eventid ~= 1 then
        return
    end

    unknown_005CH(itemref)
    var_0001 = _ItemSelectModal()
    var_0002 = unknown_092DH(var_0001)
    var_0003 = {var_0001[2], var_0001[3], var_0001[4]}
    bark(itemref, "@Tym Vas Flam@")
    if not unknown_0906H() then
        var_0004 = unknown_0024H(621)
        if not var_0004 then
            unknown_0089H(18, var_0004)
            unknown_0089H(0, var_0004)
            var_0005 = unknown_0026H(var_0003)
            if var_0005 then
                var_0005 = _SetNPCProperty(var_0004, 1, 3)
                var_0005 = unknown_0041H(621, var_0004, itemref)
                var_0005 = unknown_0002H(12, 7715, 17530, var_0004)
                var_0005 = unknown_0002H(14, 7715, 17453, var_0004)
            else
                var_0000 = true
            end
        else
            var_0000 = true
        end
        var_0005 = unknown_0001H(itemref, {17530, 17519, 17520, 8042, 65, 8536, var_0002, 7769})
        unknown_0053H(-1, 0, 0, 0, var_0003[2], var_0003[1], 13)
    else
        var_0000 = true
    end

    if var_0000 then
        var_0005 = unknown_0001H(itemref, {1542, 17493, 17519, 17520, 8554, var_0002, 7769})
    end
end