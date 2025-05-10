--- Best guess: Manages the "In Hur Grav Ylem" spell, creating a magical effect or item (ID 399) at a selected location, with a fallback effect if the spell fails.
function func_067C(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid ~= 1 then
        return
    end

    unknown_005CH(itemref)
    var_0000 = object_select_modal()
    var_0001 = unknown_092DH(var_0000)
    bark(itemref, "@In Hur Grav Ylem@")
    if not unknown_0906H() then
        var_0002 = unknown_0041H(399, var_0000, itemref)
        var_0002 = unknown_0001H(itemref, {17530, 17514, 17519, 17520, 8047, 65, 8536, var_0001, 7769})
    else
        var_0002 = unknown_0001H(itemref, {1542, 17493, 17514, 17519, 17520, 8559, var_0001, 7769})
    end
end