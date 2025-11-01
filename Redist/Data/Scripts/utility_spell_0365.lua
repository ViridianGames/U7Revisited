--- Best guess: Manages the "Sanct Lor" spell, granting invisibility (ID 1645) to a selected target, with a fallback effect if the spell fails.
function utility_spell_0365(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = object_select_modal()
        halt_scheduled(objectref)
        var_0001 = utility_unknown_1069(var_0000)
        bark(objectref, "@Sanct Lor@")
        if not utility_unknown_1030() then
            var_0002 = execute_usecode_array(objectref, {17514, 17520, 8047, 67, 8536, var_0001, 7769})
            var_0002 = delayed_execute_usecode_array(4, {1645, 17493, 7715}, var_0000)
        else
            var_0002 = execute_usecode_array(objectref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 2 then
        set_item_flag(0, objectref)
    end
end