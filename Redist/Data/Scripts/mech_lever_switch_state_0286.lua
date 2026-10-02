--- Best guess: Manages a lever or switch interaction, setting specific game state values (likely for a puzzle or mechanism) and triggering an event with object ID 275.
function utility_event_0286(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid ~= 2 then
        return
    end

    utility_spell_0774(objectref, 242)
    var_0000 = 275
    var_0001 = 5
    var_0002 = 1
    utility_unknown_0772(var_0002, var_0001, var_0000)
end