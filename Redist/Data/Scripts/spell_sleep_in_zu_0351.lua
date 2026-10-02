--- Best guess: Manages the "In Zu" spell, putting a selected target (ID 72) to sleep, with a fallback effect if the spell fails.
function utility_spell_0351(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = utility_unknown_1069(var_0000)
    halt_scheduled(objectref)
    bark(objectref, "@In Zu@")
    if utility_unknown_1030() and var_0000[1] ~= 0 then
        var_0002 = set_to_attack(72, var_0000, objectref)
        var_0003 = execute_usecode_array(objectref, {17505, 17530, 17511, 17511, 8549, var_0001, 7769})
    else
        var_0003 = execute_usecode_array(objectref, {1542, 17493, 17511, 8549, var_0001, 7769})
    end
end