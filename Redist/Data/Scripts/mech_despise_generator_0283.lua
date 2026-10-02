--- Best guess: Manages a generator mechanic in the Despise dungeon, updating its state and triggering an event or object (ID 617) with specific properties, likely for a puzzle or environmental effect.
function utility_event_0283(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 2 then
        return
    end

    utility_spell_0774(objectref, 234)
    var_0000 = get_npc_name(617)
    set_schedule_type(15, 617)
    var_0001 = delayed_execute_usecode_array(25, {617, 17493, 7715}, 617)
end