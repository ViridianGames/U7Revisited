--- Best guess: Sets item type and state based on event ID, destroying items for specific events.
function utility_event_0825(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = arg2
    if var_0000 == 1 or var_0000 == 2 then
        set_object_type(var_0001, var_0002) --- Guess: Sets item type
        destroy_object(var_0002) --- Guess: Destroys item
        play_sound_effect(46) --- Guess: Triggers event
        set_object_state(true, objectref) --- Guess: Sets item state
    elseif var_0000 == 7 then
        set_object_type(var_0001, var_0002) --- Guess: Sets item type
        destroy_object(var_0002) --- Guess: Destroys item
        play_sound_effect(46) --- Guess: Triggers event
        set_object_state(true, objectref) --- Guess: Sets item state
    elseif var_0000 == 5 then
        set_object_state(true, objectref) --- Guess: Sets item state
    elseif var_0000 == 6 then
        set_object_state(false, objectref) --- Guess: Sets item state
    end
end