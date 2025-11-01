--- Best guess: Manages an item interaction, likely a lever or switch, updating its state and triggering a specific game event or object (ID 617) with predefined properties.
function utility_event_0285(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 2 then
        return
    end

    var_0000 = get_object_position(objectref)
    utility_spell_0774(objectref, 238)
    var_0001 = delayed_execute_usecode_array(25, {617, 17493, 7715}, 617)
end