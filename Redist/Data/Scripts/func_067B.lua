--- Best guess: Manages the "In Sanct Grav" spell, creating a protective wall or barrier (ID 768) at a selected location, with a fallback effect if the spell fails.
function func_067B(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0000 = false
    if eventid ~= 1 then
        return
    end

    unknown_005CH(itemref)
    var_0001 = _ItemSelectModal()
    bark(itemref, "@In Sanct Grav@")
    var_0002 = var_0001[2] + 1
    var_0003 = var_0001[3] + 1
    var_0004 = var_0001[4]
    var_0005 = {var_0002, var_0003, var_0004}
    var_0006 = unknown_0085H(0, 768, var_0005)
    if unknown_0906H() and var_0006 then
        var_0007 = unknown_0001H(itemref, {17511, 17510, 7781})
        var_0008 = unknown_0024H(768)
        if not var_0008 then
            var_0009 = unknown_0026H(var_0005)
            if not var_0009 then
                var_000A = unknown_0015H(200, var_0008)
                var_0009 = unknown_0002H(var_000A, 200, 8493, var_0008)
            end
        else
            var_0000 = true
        end
    else
        var_0000 = true
    end

    if var_0000 then
        var_0007 = unknown_0001H(itemref, {1542, 17493, 17511, 17510, 7781})
    end
end