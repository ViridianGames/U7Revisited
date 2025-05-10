--- Best guess: Manages the "In Zu" spell, putting a selected target (ID 72) to sleep, with a fallback effect if the spell fails.
function func_065F(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = unknown_092DH(var_0000)
    unknown_005CH(objectref)
    bark(objectref, "@In Zu@")
    if unknown_0906H() and var_0000[1] ~= 0 then
        var_0002 = unknown_0041H(72, var_0000, objectref)
        var_0003 = unknown_0001H(objectref, {17505, 17530, 17511, 17511, 8549, var_0001, 7769})
    else
        var_0003 = unknown_0001H(objectref, {1542, 17493, 17511, 8549, var_0001, 7769})
    end
end