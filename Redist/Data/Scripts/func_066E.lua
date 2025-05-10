--- Best guess: Manages the "In Flam Grav" spell, creating a fire wall or explosion (ID 895) at a selected location, with a fallback effect if the spell fails.
function func_066E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = unknown_092DH(var_0000)
    unknown_005CH(objectref)
    bark(objectref, "@In Flam Grav@")
    if not unknown_0906H() then
        var_0002 = unknown_0001H(objectref, {17511, 17510, 8549, var_0001, 8025, 65, 7768})
        var_0003 = unknown_0024H(895)
        if not var_0003 then
            var_0004 = var_0000[2] + 1
            var_0005 = var_0000[3] + 1
            var_0006 = var_0000[4]
            var_0007 = {var_0004, var_0005, var_0006}
            var_0008 = unknown_0026H(var_0007)
            unknown_0089H(18, var_0003)
            var_0009 = unknown_0015H(100, var_0003)
            var_0008 = unknown_0002H(var_0009, 100, 8493, var_0003)
        end
    else
        var_0002 = unknown_0001H(objectref, {1542, 17493, 17511, 17510, 8549, var_0001, 7769})
    end
end