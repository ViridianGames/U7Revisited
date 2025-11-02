--- Best guess: Manages the "In Flam Grav" spell, creating a fire wall or explosion (ID 895) at a selected location, with a fallback effect if the spell fails.
function utility_spell_0366(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    var_0001 = utility_unknown_1069(var_0000)
    halt_scheduled(objectref)
    bark(objectref, "@In Flam Grav@")
    if not utility_unknown_1030() then
        var_0002 = execute_usecode_array(objectref, {17511, 17510, 8549, var_0001, 8025, 65, 7768})
        var_0003 = create_new_object(895)
        if not var_0003 then
            var_0004 = var_0000[2] + 1
            var_0005 = var_0000[3] + 1
            var_0006 = var_0000[4]
            var_0007 = {var_0004, var_0005, var_0006}
            var_0008 = update_last_created(var_0007)
            set_item_flag(18, var_0003)
            var_0009 = set_object_quality(100, var_0003)
            var_0008 = delayed_execute_usecode_array(var_0009, 100, 8493, var_0003)
        end
    else
        var_0002 = execute_usecode_array(objectref, {1542, 17493, 17511, 17510, 8549, var_0001, 7769})
    end
end