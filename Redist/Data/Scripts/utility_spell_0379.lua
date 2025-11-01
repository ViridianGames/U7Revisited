--- Best guess: Manages the "In Sanct Grav" spell, creating a protective wall or barrier (ID 768) at a selected location, with a fallback effect if the spell fails.
function utility_spell_0379(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0000 = false
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    var_0001 = object_select_modal()
    bark(objectref, "@In Sanct Grav@")
    var_0002 = var_0001[2] + 1
    var_0003 = var_0001[3] + 1
    var_0004 = var_0001[4]
    var_0005 = {var_0002, var_0003, var_0004}
    var_0006 = is_not_blocked(0, 768, var_0005)
    if utility_unknown_1030() and var_0006 then
        var_0007 = execute_usecode_array(objectref, {17511, 17510, 7781})
        var_0008 = create_new_object(768)
        if not var_0008 then
            var_0009 = update_last_created(var_0005)
            if not var_0009 then
                var_000A = set_item_quality(200, var_0008)
                var_0009 = delayed_execute_usecode_array(var_000A, 200, 8493, var_0008)
            end
        else
            var_0000 = true
        end
    else
        var_0000 = true
    end

    if var_0000 then
        var_0007 = execute_usecode_array(objectref, {1542, 17493, 17511, 17510, 7781})
    end
end