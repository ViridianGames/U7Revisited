--- Best guess: Manages the "In Hur Grav Ylem" spell, creating a magical effect or item (ID 399) at a selected location, with a fallback effect if the spell fails.
function utility_spell_0380(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    var_0000 = object_select_modal()
    var_0001 = utility_unknown_1069(var_0000)
    bark(objectref, "@In Hur Grav Ylem@")
    if not utility_unknown_1030() then
        var_0002 = set_to_attack(399, var_0000, objectref)
        var_0002 = execute_usecode_array(objectref, {17530, 17514, 17519, 17520, 8047, 65, 8536, var_0001, 7769})
    else
        var_0002 = execute_usecode_array(objectref, {1542, 17493, 17514, 17519, 17520, 8559, var_0001, 7769})
    end
end