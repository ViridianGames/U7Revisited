--- Best guess: Manages the "An Por" spell, teleporting a target (ID 408) to a new location, with a fallback effect if the spell fails.
function func_065C(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = unknown_092DH(var_0000)
    unknown_005CH(itemref)
    bark(itemref, "@An Por@")
    if unknown_0906H() and var_0000[1] ~= 0 then
        var_0002 = unknown_0041H(408, var_0000, itemref)
        var_0003 = unknown_0001H(itemref, {17505, 17530, 17511, 17511, 8549, var_0001, 7769})
    else
        var_0003 = unknown_0001H(itemref, {1542, 17493, 17511, 8549, var_0001, 7769})
    end
end