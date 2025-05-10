--- Best guess: Manages the "An Grav" spell, dispelling electrical or trap effects (IDs 902, 900, 895, 768) on a selected target, with a fallback effect if the spell fails.
function func_066A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = unknown_092DH(var_0000)
    unknown_005CH(itemref)
    var_0002 = {902, 900, 895, 768}
    bark(itemref, "@An Grav@")
    if not unknown_0906H() then
        var_0003 = unknown_0001H(itemref, {17514, 17520, 8559, var_0001, 8025, 65, 7768})
        for var_0004 in ipairs(var_0002) do
            if var_0006 == get_object_shape(var_0000) then
                var_0003 = unknown_0025H(var_0000)
                if not var_0003 then
                    var_0003 = unknown_0026H(-358)
                    unknown_005CH(var_0000)
                end
            end
        end
    else
        var_0003 = unknown_0001H(itemref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
    end
end