--- Best guess: Manages the "An Grav" spell, dispelling electrical or trap effects (IDs 902, 900, 895, 768) on a selected target, with a fallback effect if the spell fails.
function utility_spell_0362(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = utility_unknown_1069(var_0000)
    halt_scheduled(objectref)
    var_0002 = {902, 900, 895, 768}
    bark(objectref, "@An Grav@")
    if not utility_unknown_1030() then
        var_0003 = execute_usecode_array(objectref, {17514, 17520, 8559, var_0001, 8025, 65, 7768})
        for var_0004 in ipairs(var_0002) do
            if var_0006 == get_object_shape(var_0000) then
                var_0003 = set_last_created(var_0000)
                if not var_0003 then
                    var_0003 = update_last_created(-358)
                    halt_scheduled(var_0000)
                end
            end
        end
    else
        var_0003 = execute_usecode_array(objectref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
    end
end